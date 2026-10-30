# frozen_string_literal: true

source "https://rubygems.org"

# The versions the Život s Béďou shop runs; the lockfile keeps CI reproducible.
gem "rails", "~> 8.1.0"
gem "solidus_api", "~> 4.8.0"
gem "solidus_backend", "~> 4.8.0"
gem "solidus_core", "~> 4.8.0"
gem "solidus_legacy_promotions", "~> 4.8.0"
gem "sqlite3", "~> 2.0"

# Unreleased sibling extension.
gem "solidus_pickup_points", github: "zivotsbedou/solidus_pickup_points"

gemspec

send(:eval_gemfile, "Gemfile-local") if File.exist? "Gemfile-local"
