module Prmd
  def self.doc(schema, options={})
    doc = (options[:prepend] || []).map do |path|
      File.open(path, 'r').read + "\n"
    end

    template_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'views', 'schemata.erb'))
    template = File.read(template_path)

    doc << schema['definitions'].map do |_, schemata|
      Erubis::Eruby.new(template).result({
        schema:          schema,
        schemata:        schemata,
        template_path:   template_path
      }) + "\n"
    end
  end
end
