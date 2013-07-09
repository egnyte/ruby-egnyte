# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'egnyte/version'

Gem::Specification.new do |spec|
  spec.name          = "egnyte"
  spec.version       = Egnyte::VERSION
  spec.authors       = ["Benjamin Coe", "Dan Reed", "Larry Kang"]
  spec.email         = ["ben@attachments.me"]
  spec.description   = %q{TODO: Ruby client for Egnyte version 1 API}
  spec.summary       = %q{TODO: Ruby client for Egnyte version 1 API. Built and maintained by Attachments.me.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "multipart-post"
  spec.add_dependency "oauth2"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
