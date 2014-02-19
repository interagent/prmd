def dereference(schemata, data)
  if data.has_key?('$ref')
    begin
      schema_id, key = data['$ref'].split('#')
      schema_id = schema_id.gsub(%r{^/}, '') # drop leading slash if one exists
      definition = key.gsub('/definitions/', '')
      schemata[schema_id]['definitions'][definition]
    rescue => error
      $stderr.puts("Failed to dereference #{data}")
      raise(error)
    end
  else
    expand_references(schemata, data)
  end
end

def expand_references(schemata, data)
  data.keys.each do |key|
    value = data[key]
    data[key] = case value
    when Hash
      dereference(schemata, value)
    when Array
      if key == 'anyOf'
        value
      else
        value.map do |item|
          if item.is_a?(Hash)
            dereference(schemata, item)
          else
            item
          end
        end
      end
    else
      value
    end
  end
  data
end

def extract_attributes(schemata, properties)
  attributes = []
  properties.each do |key, value|
    #normalize single value types to arrays
    if value['type'].is_a?(String)
      value['type'] = [value['type']]
    end

    # found a reference to another element:
    if value.has_key?('anyOf')
      descriptions = []
      examples = []

      # sort anyOf! always show unique identifier first
      anyof = value['anyOf'].sort_by do |property|
        property['$ref'].split('/').last.gsub('id', 'a')
      end

      anyof.each do |ref|
        nested_field = dereference(schemata, ref)
        descriptions << nested_field['description']
        examples << nested_field['example']
      end

      # avoid repetition :}
      if descriptions.size > 1
        descriptions.first.gsub!(/ of (this )?.*/, "")
        descriptions[1..-1].map { |d| d.gsub!(/unique /, "") }
      end
      description = descriptions.join(" or ")
      example = doc_example(*examples)
      attributes << [key, "string", description, example]

    # found a nested object
    elsif value['type'] == ['object'] && value['properties']
      properties = value['properties'].sort_by { |k, v| k }

      properties.each do |prop_name, prop_value|
        new_key = "#{key}:#{prop_name}"
        attributes << [new_key, doc_type(prop_value),
          prop_value['description'], doc_example(prop_value['example'])]
      end

    # just a regular attribute
    else
      description = value['description']
      if value['enum']
        description += '<br/><b>one of:</b>' + doc_example(*value['enum'])
      end
      example = doc_example(value['example'])
      attributes << [key, doc_type(value),
        description, example]
    end
  end
  return attributes
end

def doc_type(property)
  schema_type = property["type"].dup
  type = "nullable " if schema_type.delete("null")
  type.to_s + (property["format"] || schema_type.first)
end

def doc_example(*examples)
  examples.map { |e| "<code>#{e.to_json}</code>" }.join(" or ")
end

module Prmd
  def self.doc(directory)
    schemata = {}
    Dir.glob(File.join(directory, '*.*')).each do |path|
      data = JSON.parse(File.read(path))
      schemata[data['id']] = data
    end

    schemata.each do |key,value|
      schemata[key] = expand_references(schemata, value)
    end

    devcenter_header_path = File.join(directory, 'devcenter_header.md')
    if File.exists?(devcenter_header_path)
      puts File.read(File.join(directory, 'devcenter_header.md'))
    end
    overview_path = File.join(directory, 'overview.md')
    if File.exists?(overview_path)
      puts File.read(File.join(directory, 'overview.md'))
    end

    schemata.each do |_, schema|
      next if (schema['links'] || []).empty?
      resource = schema['id'].split('/').last
      if schema['definitions'].has_key?('identity')
        identifiers = schema['definitions']['identity']['anyOf'].map {|ref| ref['$ref'].split('/').last }
        identity = resource + '_' + identifiers.join('_or_')
      end
      serialization = {}
      if schema['properties']
        schema['properties'].each do |key, value|
          unless value.has_key?('properties')
            serialization[key] = value['example']
          else
            serialization[key] = {}
            value['properties'].each do |k,v|
              serialization[key][k] = v['example']
            end
          end
        end
      else
        serialization.merge!(schema['example'])
      end

      title = schema['title'].split(' - ', 2).last

      puts Erubis::Eruby.new(File.read(File.dirname(__FILE__) + "/views/endpoint.erb")).result({
        identifiers:     identifiers,
        identity:        identity,
        resource:        resource,
        schema:          schema,
        schemata:        schemata,
        serialization:   serialization,
        title:           title,
        params_template: File.read(File.dirname(__FILE__) + "/views/parameters.erb"),
      })
    end
  end
end
