module Prmd
  class Schema
    attr_reader :data

    def initialize(new_data = {})
      @data = convert_type_to_array(new_data)
      @schemata_examples = {}
    end

    def convert_type_to_array(datum)
      case datum
      when Array
        datum.map { |element| convert_type_to_array(element) }
      when Hash
        if datum.key?('type') && datum['type'].is_a?(String)
          datum['type'] = [*datum['type']]
        end
        datum.each_with_object({}) do |(k, v), hash|
          hash[k] = convert_type_to_array(v)
        end
      else
        datum
      end
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

    def merge!(schema)
      if schema.is_a?(Schema)
        @data.merge!(schema.data)
      else
        @data.merge!(schema)
      end
    end

    def dereference(reference)
      if reference.is_a?(Hash)
        if reference.key?('$ref')
          value = reference.dup
          key = value.delete('$ref')
        else
          return [nil, reference] # no dereference needed
        end
      else
        key, value = reference, {}
      end
      begin
        datum = @data
        key.gsub(/[^#]*#\//, '').split('/').each do |fragment|
          datum = datum[fragment]
        end
        # last dereference will have nil key, so compact it out
        # [-2..-1] should be the final key reached before deref
        dereferenced_key, dereferenced_value = dereference(datum)
        [
          [key, dereferenced_key].compact.last,
          [dereferenced_value, value].inject({}, &:merge)
        ]
      rescue => error
        $stderr.puts("Failed to dereference `#{key}`")
        raise(error)
      end
    end

    def schema_value_example(value)
      if value.key?('example')
        value['example']
      elsif value.key?('anyOf')
        id_ref = value['anyOf'].find do |ref|
          ref['$ref'] && ref['$ref'].split('/').last == 'id'
        end
        ref = id_ref || value['anyOf'].first
        schema_example(ref)
      elsif value.key?('properties') # nested properties
        schema_example(value)
      elsif value.key?('items') # array of objects
        _, items = dereference(value['items'])
        if value['items'].key?('example')
          [items['example']]
        else
          [schema_example(items)]
        end
      end
    end

    def schema_example(schema)
      _, _schema = dereference(schema)

      if _schema.key?('example')
        _schema['example']
      elsif _schema.key?('properties')
        example = {}
        _schema['properties'].each do |key, value|
          _, value = dereference(value)
          example[key] = schema_value_example(value)
        end
        example
      elsif _schema.key?('items')
        schema_value_example(_schema)
      end
    end

    def schemata_example(schemata_id)
      _, schema = dereference("#/definitions/#{schemata_id}")
      @schemata_examples[schemata_id] ||= begin
        schema_example(schema)
      end
    end

    def href
      (@data['links'] && @data['links'].find { |link| link['rel'] == 'self' } || {})['href']
    end

    def to_json
      new_json = JSON.pretty_generate(@data)
      # nuke empty lines
      new_json = new_json.split("\n").reject(&:empty?).join("\n") + "\n"
      new_json
    end

    def to_yaml
      YAML.dump(@data)
    end

    def to_s
      to_json
    end

    private :convert_type_to_array
    protected :data
  end
end
