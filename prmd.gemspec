# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prmd/version'

Gem::Specification.new do |spec|
  spec.name          = "prmd"
  spec.version       = Prmd::VERSION
  spec.authors       = ["geemus"]
  spec.email         = ["geemus@gmail.com"]
  spec.description   = %q{schema to rule them all}
  spec.summary       = %q{schema to rule them all}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "diff-lcs"
  spec.add_dependency "erubis"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
