# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'egnyte/version'

Gem::Specification.new do |spec|
  spec.name          = "egnyte"
  spec.version       = Egnyte::VERSION
  spec.authors       = ["Benjamin Coe", "Dan Reed", "Larry Kang", "Jesse Miller", "David Pfeffer"]
  spec.email         = ["dpfeffer@egnyte.com"]
  spec.description   = %q{Ruby client for Egnyte Public API}
  spec.summary       = %q{Ruby client for Egnyte Public API. Started by Attachments.me.  Extended and maintained by Egnyte.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "multipart-post"
  spec.add_dependency "mime-types"
  spec.add_dependency "oauth2"
  spec.add_dependency "json"
  spec.add_dependency "os"
  spec.add_dependency "rest-client"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
