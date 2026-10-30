# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

# Create the dummy app if it's still missing.
dummy_env = "#{__dir__}/dummy/config/environment.rb"
system "bin/rake extension:test_app" unless File.exist? dummy_env
require dummy_env

require "solidus_dev_support/rspec/feature_helper"
require "webmock/rspec"

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

SolidusDevSupport::TestingSupport::Factories.load_for(SolidusPacketa::Engine)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false
end
