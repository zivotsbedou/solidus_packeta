# frozen_string_literal: true

module SolidusPacketa
  # A packet Packeta still refuses after the retries stays as a failed job for staff to resolve.
  class CancelPacketJob < ActiveJob::Base
    retry_on Error, wait: :polynomially_longer, attempts: 5

    def perform(shipment)
      Packet.cancel(shipment)
    end
  end
end
