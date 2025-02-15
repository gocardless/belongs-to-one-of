# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "belongs_to_one_of/version"

Gem::Specification.new do |spec|
  spec.name          = "belongs_to_one_of"
  spec.version       = BelongsToOneOf::VERSION
  spec.authors       = ["GoCardless Engineering"]
  spec.email         = ["engineering@gocardless.com"]

  spec.summary       = "A small library that helps with models which can have " \
                       "multiple parent model types"
  spec.homepage      = "https://github.com/gocardless/belongs-to-one-of"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "activerecord", ">= 7.0", "< 9"
  spec.add_dependency "activesupport", ">= 7.0", "< 9"
  spec.metadata["rubygems_mfa_required"] = "true"
end
