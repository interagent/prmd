module Prmd
  class Schema

    def [](key)
      @data[key]
    end

    def []=(key, value)
      @data[key] = value
    end

    def self.load(path, options={})
      unless File.directory?(path)
        data = JSON.parse(File.read(path))
      else
        data = {
          '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
          'definitions' => {},
          'properties'  => {},
          'type'        => ['object']
        }

        if options[:meta] && File.exists?(options[:meta])
          data.merge!(JSON.parse(File.read(options[:meta])))
        end

        Dir.glob(File.join(path, '**', '*.json')).each do |schema|
          schema_data = JSON.parse(File.read(schema))
          id = if schema_data['id']
            schema_data['id'].gsub('schema/', '')
          end
          next if id.nil? || id[0..0] == '_' # FIXME: remove this exception?

          data['definitions'][id] = schema_data
          reference_localizer = lambda do |datum|
            case datum
            when Array
              datum.map {|element| reference_localizer.call(element)}
            when Hash
              if datum.has_key?('$ref')
                datum['$ref'] = datum['$ref'].gsub(%r{/schema/([^#]*)#}, '#/definitions/\1')
              end
              if datum.has_key?('href')
                datum['href'] = datum['href'].gsub(%r{%2Fschema%2F([^%]*)%23%2F}, '%23%2Fdefinitions%2F\1%2F')
              end
              datum.each { |k,v| datum[k] = reference_localizer.call(v) }
            else
              datum
            end
          end
          reference_localizer.call(data['definitions'][id])

          data['properties'][id] = { '$ref' => "#/definitions/#{id}" }
        end
      end

      self.new(data)
    end

    def initialize(new_data = {})
      convert_type_to_array = lambda do |datum|
        case datum
        when Array
          datum.map { |element| convert_type_to_array.call(element) }
        when Hash
          if datum.has_key?('type') && datum['type'].is_a?(String)
            datum['type'] = [*datum['type']]
          end
          datum.each { |k,v| datum[k] = convert_type_to_array.call(v) }
        else
          datum
        end
      end
      @data = convert_type_to_array.call(new_data)
    end

    def dereference(reference)
      if reference.is_a?(Hash)
        if reference.has_key?('$ref')
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
        key.gsub(%r{[^#]*#/}, '').split('/').each do |fragment|
          datum = datum[fragment]
        end
        # last dereference will have nil key, so compact it out
        # [-2..-1] should be the final key reached before deref
        dereferenced_key, dereferenced_value = dereference(datum)
        [
          [key, dereferenced_key].compact.last,
          [dereferenced_value, value].inject({}) { |composite, element| composite.merge(element) }
        ]
      rescue => error
        $stderr.puts("Failed to dereference `#{key}`")
        raise(error)
      end
    end

    def to_s
      new_json = JSON.pretty_generate(@data)
      # nuke empty lines
      new_json = new_json.split("\n").delete_if {|line| line.empty?}.join("\n") + "\n"
      new_json
    end

  end
end
