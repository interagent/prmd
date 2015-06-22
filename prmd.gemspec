# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prmd/version'

Gem::Specification.new do |spec|
  spec.name          = 'prmd'
  spec.version       = Prmd::VERSION
  spec.authors       = ['geemus']
  spec.email         = ['geemus@gmail.com']
  spec.description   = 'scaffold, verify and generate docs from JSON Schema'
  spec.summary       = 'JSON Schema tooling'
  spec.homepage      = 'https://github.com/heroku/prmd'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'erubis',      '~> 2.7'
  spec.add_dependency 'json_schema', '~> 0.3', '>= 0.3.1'

  spec.add_development_dependency 'bundler',  '~> 1.3'
  spec.add_development_dependency 'rake',     '~> 10.3'
  spec.add_development_dependency 'minitest', '~> 5.4'
end
