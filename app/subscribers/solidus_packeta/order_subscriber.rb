# frozen_string_literal: true

module SolidusPacketa
  class OrderSubscriber
    include Omnes::Subscriber

    handle :order_canceled, with: :cancel_packets, id: :solidus_packeta_cancel_packets

    def cancel_packets(event)
      event[:order].shipments.each do |shipment|
        next unless shipment.pickup_carrier == SolidusPacketa.config.carrier && shipment.tracking.present?

        CancelPacketJob.perform_later(shipment)
      end
    end
  end
end
