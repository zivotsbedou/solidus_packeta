# frozen_string_literal: true

require "solidus_pickup_points"
require "solidus_packeta/configuration"
require "solidus_packeta/version"
require "solidus_packeta/engine"

module SolidusPacketa
  # Packeta point IDs as its picker sends them.
  POINT_ID = /\A\d{1,10}\z/

  # A Packeta fault, an unreachable API or a shipment Packeta cannot take; the message says which.
  class Error < StandardError; end
end
