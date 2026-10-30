# frozen_string_literal: true

module SolidusPacketa
  class Configuration
    # Public key for the browser picker and the server-only password for packets (Packeta client section).
    attr_accessor :api_key, :api_password

    # Sender label (the API's "eshop"); needed when the Packeta account has more than one sender.
    attr_accessor :sender

    # Shipping method carrier that delivers to Packeta points.
    attr_accessor :carrier

    # Unit of Solidus variant weights: "kg", "g", "lb" or "oz".
    attr_accessor :weight_unit

    # Packeta label format, e.g. "A6 on A6" or "A7 on A4".
    attr_accessor :label_format

    attr_accessor :api_url

    def initialize
      @carrier = "packeta"
      @weight_unit = "kg"
      @label_format = "A6 on A6"
      @api_url = "https://www.zasilkovna.cz/api/rest"
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration

    def configure
      yield configuration
    end
  end
end
