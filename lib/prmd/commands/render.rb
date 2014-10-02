require 'prmd/core/renderer'

module Prmd
  module Render
    def self.get_template(options)
      template = options.fetch(:template) do
        abort 'render: Template was not provided'
      end
      template_dir = File.expand_path(template)
      # to keep backward compatibility
      unless File.directory?(template_dir)
        template_dir = File.dirname(template)
      end
      Prmd::Template.load_template('schema.erb', template_dir)
    end
  end

  def self.render(schema, options={})
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
