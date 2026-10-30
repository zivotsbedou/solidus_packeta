# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusPacketa::Packet do
  let(:shipment) { packeta_shipment }

  it "creates one packet for the stored point with the product weight" do
    stub_packeta("<status>ok</status><result><id>1234567890</id><barcode>Z1234567890</barcode></result>")

    expect(described_class.create(shipment)).to eq("1234567890")
    expect(described_class.create(shipment.reload)).to eq("1234567890")

    expect(packeta_request("createPacket").with { |request|
      packet = Nokogiri::XML(request.body).at("/createPacket")
      packet.at("apiPassword").text == "fixturepassword" &&
        packet.at("packetAttributes/addressId").text == "10178" &&
        packet.at("packetAttributes/number").text == shipment.order.number &&
        packet.at("packetAttributes/weight").text == "0.450" &&
        packet.at("packetAttributes/eshop").nil?
    }).to have_been_made.once
  end

  it "converts the configured weight unit to kg" do
    SolidusPacketa.config.weight_unit = "g"
    shipment.inventory_units.each { |unit| unit.variant.update!(weight: 450) }
    expect(described_class.weight(shipment.reload)).to eq(0.45)
  ensure
    SolidusPacketa.config.weight_unit = "kg"
  end

  it "names the products without a weight and sends nothing" do
    variant = shipment.inventory_units.first.variant
    variant.update!(weight: 0)

    expect { described_class.create(shipment.reload) }.to raise_error(SolidusPacketa::Error, /#{Regexp.escape(variant.descriptive_name)}/)
    expect(packeta_request("createPacket")).not_to have_been_made
  end

  it "raises the Packeta fault and keeps the shipment without tracking" do
    stub_packeta("<status>fault</status><fault>PacketAttributesFault</fault><string>Invalid attributes</string><detail>weight</detail>")

    expect { described_class.create(shipment) }.to raise_error(SolidusPacketa::Error, "PacketAttributesFault: Invalid attributes: weight")
    expect(shipment.reload.tracking).to be_nil
  end

  it "decodes the label PDF" do
    shipment.update_columns(tracking: "1234567890")
    stub_packeta("<status>ok</status><result>#{Base64.strict_encode64("%PDF-1.7")}</result>")

    expect(described_class.label_pdf(shipment)).to eq("%PDF-1.7")
  end
end
