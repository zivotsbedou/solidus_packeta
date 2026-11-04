# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusPacketa::OrderSubscriber do
  include ActiveJob::TestHelper

  it "cancels the packet of a canceled order" do
    shipment = packeta_shipment
    shipment.update_columns(tracking: "1234567890")
    stub_packeta("<status>ok</status><result/>")

    perform_enqueued_jobs { shipment.order.canceled_by(create(:admin_user)) }

    expect(packeta_request("cancelPacket").with { |request|
      Nokogiri::XML(request.body).at("/cancelPacket/packetId").text == "1234567890"
    }).to have_been_made.once
  end

  it "sends nothing for a shipment without a packet" do
    shipment = packeta_shipment

    perform_enqueued_jobs { shipment.order.canceled_by(create(:admin_user)) }

    expect(packeta_request("cancelPacket")).not_to have_been_made
  end
end
