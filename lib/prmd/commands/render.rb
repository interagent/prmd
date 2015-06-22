require_relative '../core/renderer'

# :nodoc:
module Prmd
  # Render helper module
  module Render
    # Retrieve the schema template
    #
    # @param [Hash<Symbol, Object>] options
    # @return (see Prmd::Template.load_template)
    def self.get_template(options)
      template = options.fetch(:template) do
        abort 'render: Template was not provided'
      end
      template_dir = File.expand_path(template)
      # to keep backward compatibility
      template_dir = File.dirname(template) unless File.directory?(template_dir)
      Prmd::Template.load_template('schema.erb', template_dir)
    end
  end

  # Render provided schema to Markdown
  #
  # @param [Prmd::Schema] schema
  # @return [String] rendered schema in Markdown
  def self.render(schema, options = {})
    renderer = Prmd::Renderer.new(template: Render.get_template(options))
    doc = ''
    if options[:prepend]
      doc <<
      options[:prepend].map { |path| File.read(path) }.join("\n") <<
      "\n"
    end
    doc << renderer.render(schema, options)
    doc
  end
end
