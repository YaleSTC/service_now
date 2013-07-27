# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_now/version'

Gem::Specification.new do |spec|
  spec.name          = "service_now"
  spec.version       = ServiceNow::VERSION
  spec.authors       = ["YaleSTC::hengchu zhang"]
  spec.email         = ["hengchu.zhang@yale.edu"]
  spec.description   = %q{Ruby wrapper for SN API requests}
  spec.summary       = %q{Ruby wrapper for SN API requests}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.add_dependency('rest-client')

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
