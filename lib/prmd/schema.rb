module Prmd
  class Schema

    attr_accessor :data

    def self.load(path)
      unless File.directory?(path)
        data = JSON.parse(File.read(path))
      else
        data = {
          '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
          'definitions' => {},
          'properties'  => {},
          'type'        => ['object']
        }

        meta_path = File.join(path, '_meta.json')
        if File.exists?(meta_path)
          data.merge!(JSON.parse(File.read(meta_path)))
        end

        Dir.glob(File.join(path, '**', '*.json')).each do |schema|
          schema_data = JSON.parse(File.read(schema))
          id = if schema_data['id']
            schema_data['id'].gsub('schema/', '')
          end
          next if id.nil? || id[0..0] == '_'

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
          if datum.has_key?('type')
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
          key = reference['$ref']
        else
          return reference # no dereference needed
        end
      else
        key = reference
      end
      begin
        datum = data
        key.gsub(%r{[^#]*#/}, '').split('/').each do |fragment|
          datum = datum[fragment]
        end
        datum
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
