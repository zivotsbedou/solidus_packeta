# frozen_string_literal: true

module Spree
  module Admin
    class PacketaLabelsController < Spree::Admin::BaseController
      before_action do
        @shipment = Spree::Shipment.find_by!(number: params[:shipment_id])
        authorize! :ship, @shipment
      end

      rescue_from SolidusPacketa::Error do |error|
        redirect_to edit_admin_order_path(@shipment.order), flash: {error: error.message}
      end

      def create
        tracking = SolidusPacketa::Packet.create(@shipment)
        redirect_to edit_admin_order_path(@shipment.order), flash: {success: t("solidus_packeta.created", tracking:)}
      end

      def show
        send_data SolidusPacketa::Packet.label_pdf(@shipment), filename: "#{@shipment.number}.pdf",
          type: "application/pdf", disposition: "inline"
      end
    end
  end
end
