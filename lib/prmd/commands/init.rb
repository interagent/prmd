require 'json'
require_relative '../template'
require_relative '../core/generator'

# :nodoc:
module Prmd
  # Schema generation
  module Generate
    # Creates a default Prmd::Generator using default templates
    #
    # @return [Prmd::Generator]
    def self.make_generator(options)
      base = Prmd::Template.load_json('init_default.json')
      template_name = options.fetch(:template) do
        abort 'render: Template was not provided'
      end
      if template_name && !template_name.empty?
        template_dir = File.expand_path(template_name)
        # to keep backward compatibility
        template_dir = File.dirname(template_name) unless File.directory?(template_dir)
        template_name = File.basename(template_name)
      else
        template_name = 'init_resource.json.erb'
        template_dir  = ''
      end
      template = Prmd::Template.load_template(template_name, template_dir)
      Prmd::Generator.new(base: base, template: template)
    end
  end

  # Generate a schema template
  #
  # @param [String] resource
  # @param [Hash<Symbol, Object>] options
  # @return [String] schema template in YAML (yaml option was enabled) else JSON
  def self.init(resource, options = {})
    gen = Generate.make_generator(template: options[:template])

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
