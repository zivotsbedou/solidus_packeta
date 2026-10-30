# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Packeta label in the admin shipment", type: :feature do
  stub_authorization!

  it "creates the packet and links its label" do
    shipment = packeta_shipment
    stub_packeta("<status>ok</status><result><id>1234567890</id></result>")

    visit spree.edit_admin_order_path(shipment.order)
    click_button "Create Packeta label"

    expect(page).to have_text("Packeta packet 1234567890 created.")
    expect(page).to have_link("Packeta label (PDF)", href: spree.admin_shipment_packeta_label_path(shipment))
    expect(shipment.reload.tracking).to eq("1234567890")
  end

  it "shows why Packeta refused the packet" do
    shipment = packeta_shipment
    stub_packeta("<status>fault</status><fault>IncorrectApiPasswordFault</fault><string>Incorrect API password.</string>")

    visit spree.edit_admin_order_path(shipment.order)
    click_button "Create Packeta label"

    expect(page).to have_text("IncorrectApiPasswordFault: Incorrect API password.")
    expect(shipment.reload.tracking).to be_nil
  end
end
