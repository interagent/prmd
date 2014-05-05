module Prmd
  def self.render(schema, options={})
    doc = ''

    if options[:prepend]
      doc << options[:prepend].map {|path| File.read(path)}.join("\n") << "\n"
    end

    doc << Erubis::Eruby.new(File.read(options[:template])).result({
      options:         options,
      schema:          schema
    })

    doc
  end
end
