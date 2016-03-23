# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'agnostic_backend/version'

Gem::Specification.new do |spec|
  spec.name          = "agnostic_backend"
  spec.version       = AgnosticBackend::VERSION
  spec.authors       = ["Iasonas Gavriilidis",
                        "Laertis Pappas",
                        "Kyriakos Kentzoglanakis"]
  spec.email         = ["i.gavriilidis@pamediakopes.gr",
                        "l.pappas@pamediakopes.gr",
                        "k.kentzoglanakis@pamediakopes.gr"]

  spec.summary       = %q{A gem to index/query ruby objects to/from remote backends}
  spec.homepage      = "https://github.com/e-travel/agnostic_backend"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.1.0' # for mandatory method keyword arguments

  spec.add_runtime_dependency "activesupport", "~> 3"
  spec.add_runtime_dependency "aws-sdk", "~> 2"
  spec.add_runtime_dependency "faraday"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "rspec", "~> 2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-html"
end
