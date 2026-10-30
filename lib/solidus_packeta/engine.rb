# frozen_string_literal: true

require "solidus_core"
require "solidus_support"
require "deface"

module SolidusPacketa
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name "solidus_packeta"

    # After the app's initializers, so a configured carrier name is the one registered.
    config.after_initialize do
      SolidusPickupPoints.config.carriers[SolidusPacketa.config.carrier] ||= SolidusPacketa::POINT_ID
    end

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
