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


    # Get the definition pointed at by the given reference.
    #
    # @param reference [Hash, String] reference to dereference. Can be a Hash
    #                                 containing a '$ref' key with a String
    #                                 reference to the definition, a the '$ref'
    #                                 value itself
    #
    # @param key [String] key from the schema that holds the given reference.
    #                     This is mainly useful if you want to get back both
    #                     the dereferenced value and its associated key, as the
    #                     given reference object could already be a dereferenced
    #                     one.
    #
    # @return [Array] the dereferenced definition and its associated key as an
    #                 array: [definition, key]. The key part could be nil when
    #                 no key argument has been given and the reference didn't
    #                 need to be dereferenced.
    #                 When the key part, is not wanted simply use:
    #                 `value = schema.dereference(ref).first`
    #
    # @raise [Exception] when the reference cannot be found in the schema
    #
    def dereference(reference, key = nil)
      # Reference can be a schema definition
      if reference.is_a?(Hash)
        if reference.has_key?('$ref')
          ref = reference['$ref']
        else
          return [reference, key] # no dereference needed
        end
      # Or the String content of a "$ref" attribute
      else
        ref = reference
      end

      # Assumes ref to be of the form '/schema/resource#/key1/key2', where
      # '/schema/resource' is actually what's held in @data.
      # Walk through each @data[keyX] until we get to the referenced definition
      datum = @data
      ref.gsub(%r{[^#]*#/}, '').split('/').each do |fragment|
        key = fragment
        datum = datum[fragment]
      end

      # Dereference the definition we found for the key in ref.
      # If datum contains a fully dereferenced object, the recursion will be
      # stopped and datum will be returned.
      dereference(datum, key)

    rescue => error
      $stderr.puts("Failed to dereference `#{ref}`")
      raise(error)
    end

    def to_s
      new_json = JSON.pretty_generate(@data)
      # nuke empty lines
      new_json = new_json.split("\n").delete_if {|line| line.empty?}.join("\n") + "\n"
      new_json
    end

  end
end
