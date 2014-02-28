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
                datum['$ref'] = datum['$ref'].gsub("/schema/#{id}#", "#/definitions/#{id}")
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
      @data = new_data
    end

    def dereference(datum)
      if datum.has_key?('$ref')
        begin
          schema_id, key = datum['$ref'].split('#')
          if schema_id.empty? # already dereferenced
            datum
          else
            definition = key.gsub('/definitions/', '')
            @data['definitions'][schema_id]['definitions'][definition]
          end
        rescue => error
          $stderr.puts("Failed to dereference #{datum}")
          raise(error)
        end
      else
        datum.keys.each do |k|
          value = datum[k]
          datum[k] = case value
          when Hash
            dereference(value)
          when Array
            if k == 'anyOf'
              value
            else
              value.map do |item|
                if item.is_a?(Hash)
                  dereference(item)
                else
                  item
                end
              end
            end
          else
            value
          end
        end
        datum
      end
    end

    def to_s
      new_json = JSON.pretty_generate(@data)
      # nuke empty lines
      new_json = new_json.split("\n").delete_if {|line| line.empty?}.join("\n")
      new_json
    end

  end
end
