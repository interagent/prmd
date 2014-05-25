module Prmd
  def self.render(schema, options={})
    doc = ''

    if options[:prepend]
      doc << options[:prepend].map {|path| File.read(path)}.join("\n") << "\n"
    end

    template_dir = File::expand_path(options[:template])
    if not File.directory?(template_dir)  # to keep backward compatibility
      template_dir = File.dirname(options[:template])
    end
    options[:template] = template_dir

    doc << Prmd::Template::render('schema.erb', template_dir, {
      options:         options,
      schema:          schema
    })

    doc
  end
end
