module Prmd
  def self.doc(schema, options={})
    doc = (options[:prepend] || []).map do |path|
      File.open(path, 'r').read + "\n"
    end

    doc << schema['definitions'].map do |_, definition|
      next if (definition['links'] || []).empty?
      resource = definition['id'].split('/').last

      identifiers = if definition['definitions'].has_key?('identity')
        identity = definition['definitions']['identity']
        (identity['anyOf'] || [identity]).map {|ref| ref['$ref'].split('/').last }
      else
        []
      end

      template_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'views', 'endpoint.erb'))
      template = File.read(template_path)

      Erubis::Eruby.new(template).result({
        definition:      definition,
        identifiers:     identifiers,
        resource:        resource,
        schema:          schema,
        template_path:   template_path
      }) + "\n"
    end
  end
end
