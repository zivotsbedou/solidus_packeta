# frozen_string_literal: true

module SolidusPacketa
  # Creates the Packeta packet for a pickup shipment and fetches its label through the REST/XML API.
  class Packet
    WEIGHT_TO_KG = {"kg" => 1, "g" => 0.001, "lb" => 0.45359237, "oz" => 0.028349523125}.freeze
    NETWORK_ERRORS = [IOError, SystemCallError, SocketError, Timeout::Error, OpenSSL::SSL::SSLError].freeze

    class << self
      # Returns the packet ID, which the shipment keeps as its tracking number.
      def create(shipment)
        raise Error, I18n.t("solidus_packeta.not_packeta") unless shipment.pickup_carrier == SolidusPacketa.config.carrier
        raise Error, I18n.t("solidus_packeta.not_ready") unless shipment.ready?

        shipment.with_lock do
          next if shipment.tracking.present?

          result = request("createPacket", packetAttributes: attributes(shipment))
          shipment.update!(tracking: result.at("id").text)
        end
        shipment.tracking
      end

      def label_pdf(shipment)
        raise Error, I18n.t("solidus_packeta.no_packet") if shipment.tracking.blank?

        result = request("packetLabelPdf", packetId: shipment.tracking, format: SolidusPacketa.config.label_format, offset: 0)
        Base64.decode64(result.text)
      end

      # Weight in kg from the variants; a product without a weight stops the packet.
      def weight(shipment)
        contents = shipment.to_package.contents
        missing = contents.map(&:variant).reject { |variant| variant.weight.to_d.positive? }
        raise Error, I18n.t("solidus_packeta.missing_weight", products: missing.map(&:descriptive_name).uniq.to_sentence) if missing.any?

        contents.sum(&:weight) * WEIGHT_TO_KG.fetch(SolidusPacketa.config.weight_unit)
      end

      private

      def attributes(shipment)
        order = shipment.order
        address = order.ship_address
        name = ::Spree::Address::Name.new(address.name)
        {
          number: order.number, name: name.first_name, surname: name.last_name, email: order.email,
          phone: address.phone, addressId: shipment.pickup_point_id, currency: order.currency,
          value: format("%.2f", shipment.item_cost), weight: format("%.3f", weight(shipment)),
          eshop: SolidusPacketa.config.sender.presence
        }
      end

      def request(action, params)
        password = SolidusPacketa.config.api_password.presence or raise Error, I18n.t("solidus_packeta.not_configured")
        body = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.public_send(action) { tags(xml, apiPassword: password, **params) }
        end.to_xml
        uri = URI(SolidusPacketa.config.api_url)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 30) do |http|
          http.post(uri.path, body, "Content-Type" => "text/xml; charset=utf-8")
        end
        raise Error, "Packeta HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        doc = Nokogiri::XML(response.body)
        return doc.at("/response/result") if doc.at("/response/status")&.text == "ok"

        raise Error, %w[fault string detail].filter_map { |node| doc.at("/response/#{node}")&.text&.squish.presence }.join(": ")
      rescue *NETWORK_ERRORS => e
        raise Error, I18n.t("solidus_packeta.unavailable", error: e.message)
      end

      # Trailing underscores keep tag names like `format` off Builder's own methods.
      def tags(xml, params)
        params.compact.each do |key, value|
          value.is_a?(Hash) ? xml.public_send(:"#{key}_") { tags(xml, value) } : xml.public_send(:"#{key}_", value.to_s)
        end
      end
    end
  end
end
