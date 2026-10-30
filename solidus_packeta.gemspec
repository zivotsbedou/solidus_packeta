# frozen_string_literal: true

require_relative "lib/solidus_packeta/version"

Gem::Specification.new do |spec|
  spec.name = "solidus_packeta"
  spec.version = SolidusPacketa::VERSION
  spec.authors = ["Život s Béďou, z.s."]
  spec.email = "ahoj@zivotsbedou.cz"

  spec.summary = "Packeta (Zásilkovna) pickup points and labels for Solidus"
  spec.description = "Registers Packeta pickup points with solidus_pickup_points and creates Packeta packets " \
                     "and labels for Solidus shipments from the admin, using product weights."
  spec.homepage = "https://github.com/zivotsbedou/solidus_packeta#readme"
  spec.license = "BSD-3-Clause"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zivotsbedou/solidus_packeta"
  spec.metadata["changelog_uri"] = "https://github.com/zivotsbedou/solidus_packeta/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.required_ruby_version = ">= 3.2"

  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(spec|bin)/|^\.})
  spec.require_paths = ["lib"]

  spec.add_dependency "deface", "~> 1.9"
  spec.add_dependency "nokogiri", ">= 1.15"
  spec.add_dependency "solidus_core", [">= 4.8", "< 5"]
  spec.add_dependency "solidus_pickup_points", "~> 0.1"
  spec.add_dependency "solidus_support", ">= 0.12.0"

  spec.add_development_dependency "solidus_dev_support", "~> 2.12"
  spec.add_development_dependency "webmock", "~> 3.25"
end
