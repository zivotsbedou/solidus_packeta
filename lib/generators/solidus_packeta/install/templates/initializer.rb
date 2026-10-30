# frozen_string_literal: true

SolidusPacketa.configure do |config|
  config.api_key = ENV.fetch("PACKETA_API_KEY", nil)
  config.api_password = ENV.fetch("PACKETA_API_PASSWORD", nil)
  config.sender = ENV.fetch("PACKETA_SENDER", nil)

  # config.carrier = "packeta"         # shipping method carrier with service level "pickup"
  # config.weight_unit = "kg"          # unit of your variant weights
  # config.label_format = "A6 on A6"
end
