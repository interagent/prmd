require 'json'
require 'prmd/template'
require 'prmd/core/generator'

module Prmd
  module Generate
    def self.make_generator
      base = Prmd::Template.load_json('init_default.json')
      template = Prmd::Template.load_template('init_resource.json.erb', '')
      Prmd::Generator.new(base: base, template: template)
    end
  end

  def self.init(resource, options = {})
    gen = Generate.make_generator

    generator_options = { resource: nil, parent: nil }
    if resource
      parent = nil
      parent, resource = resource.split('/') if resource.include?('/')
      generator_options[:parent] = parent
      generator_options[:resource] = resource
    end

    schema = gen.generate(generator_options)

    if options[:yaml]
      schema.to_yaml
    else
      schema.to_json
    end
  end
end
