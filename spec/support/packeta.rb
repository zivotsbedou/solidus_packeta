# frozen_string_literal: true

module PacketaHelpers
  def stub_packeta(*results)
    stub_request(:post, SolidusPacketa.config.api_url)
      .to_return(*results.map { |xml| {body: %(<?xml version="1.0"?><response>#{xml}</response>)} })
  end

  def packeta_request(action)
    a_request(:post, SolidusPacketa.config.api_url).with { |request| Nokogiri::XML(request.body).root.name == action }
  end

  # A ready Packeta shipment whose single item weighs 0.45 kg.
  def packeta_shipment
    order = create(:order_ready_to_ship)
    order.line_items.each { |item| item.variant.update!(weight: 0.45) }
    order.shipments.first.tap do |shipment|
      shipment.shipping_method.update!(carrier: "packeta", service_level: "pickup")
      shipment.update_columns(tracking: nil, pickup_carrier: "packeta", pickup_point_id: "10178",
        pickup_name: "Z-BOX Korunní", pickup_address: "Korunní 1, Praha")
    end
  end
end

RSpec.configure do |config|
  config.include PacketaHelpers
  config.before { SolidusPacketa.config.api_password = "fixturepassword" }
end
