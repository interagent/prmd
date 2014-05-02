module Prmd
  def self.render(schema, options={})
    doc = ''

    if options[:prepend]
      doc << options.prepend.map {|path| File.read(path)}.join("\n") << "\n"
    end

    doc << schema['definitions'].map do |_, schemata|
      Erubis::Eruby.new(File.read(options[:template])).result({
        options:         options,
        schema:          schema,
        schemata:        schemata
      })
    end.join("\n") << "\n"
  end
end
