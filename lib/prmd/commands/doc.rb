module Prmd
  def self.doc(schema, options={})
    doc = (options[:prepend] || []).map do |path|
      File.open(path, 'r').read + "\n"
    end

    doc << schema['definitions'].map do |_, schemata|
      identifiers = if schemata['definitions'].has_key?('identity')
        identity = schemata['definitions']['identity']
        (identity['anyOf'] || [identity]).map {|ref| ref['$ref'].split('/').last }
      else
        []
      end

      template_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'views', 'schemata.erb'))
      template = File.read(template_path)

      Erubis::Eruby.new(template).result({
        identifiers:     identifiers,
        schema:          schema,
        schemata:        schemata,
        template_path:   template_path
      }) + "\n"
    end
  end
end
