module Prmd
  def self.doc(schema, options={})
    root_url = schema['links'].find{|l| l['rel'] == 'self'}['href']

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

      serialization = {}
      if definition['properties']
        definition['properties'].each do |key, value|
          _, value = schema.dereference(value)
          if value.has_key?('properties')
            serialization[key] = {}
            value['properties'].each do |k,v|
              serialization[key][k] = schema.dereference(v).last['example']
            end
          else
            serialization[key] = value['example']
          end
        end
      else
        serialization.merge!(definition['example'])
      end

      title = definition['title'].split(' - ', 2).last

      template_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'views', 'endpoint.erb'))
      template = File.read(template_path)

      Erubis::Eruby.new(template).result({
        definition:      definition,
        identifiers:     identifiers,
        resource:        resource,
        root_url:        root_url,
        schema:          schema,
        serialization:   serialization,
        template_path:   template_path,
        title:           title
      }) + "\n"
    end
  end
end
