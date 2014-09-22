module Prmd
  def self.render(schema, options={})
    doc = ''
    options[:http_header] ||= {}
    options[:http_header] = {
      "Content-Type" => 'application/json'
    }.merge(options[:http_header])
    options[:doc] ||= {}
    options[:doc][:url_style] ||= 'default'
    options[:doc][:disable_title_and_description] ||= false

    if options[:prepend]
      doc << options[:prepend].map {|path| File.read(path)}.join("\n") << "\n"
    end

    template = options.fetch(:template) { abort "render: Template was not provided" }
    template_dir = File.expand_path(template)
    if not File.directory?(template_dir)  # to keep backward compatibility
      template_dir = File.dirname(template)
    end

    doc << Prmd::Template.render('schema.erb', template_dir, {
      options:         options,
      schema:          schema
    })

    doc
  end
end
