# frozen_string_literal: true

module SolidusPacketa
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path("templates", __dir__)

      def self.exit_on_failure?
        true
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/solidus_packeta.rb"
      end

      # The pickup point columns come from solidus_pickup_points.
      def install_pickup_points
        generate "solidus_pickup_points:install", *("--auto-run-migrations" if options[:auto_run_migrations])
      end
    end
  end
end
