require 'prmd/schema'
require 'prmd/core/schema_hash'

# :nodoc:
module Prmd
  # Schema combiner
  class Combiner
    #
    # @param [Hash<Symbol, Object>] properties
    def initialize(properties = {})
      @properties = properties
      @schema = properties.fetch(:schema)
      @base = properties.fetch(:base, {})
      @meta = properties.fetch(:meta, {})
    end

    # @param [Array] array
    # @return [Array]
    def reference_localizer_array(array)
      array.map { |element| reference_localizer(element) }
    end

    # @param [Hash] hash
    # @return [Hash]
    def reference_localizer_hash(hash)
      if hash.key?('$ref')
        hash['$ref'] = '#/definitions' + hash['$ref'].gsub('#', '')
                                                     .gsub('/schemata', '')
      end
      if hash.key?('href') && hash['href'].is_a?(String)
        hash['href'] = hash['href'].gsub('%23', '')
                                   .gsub(/%2Fschemata(%2F[^%]*%2F)/,
                                         '%23%2Fdefinitions\1')
      end
      hash.each_with_object({}) { |(k, v), r| r[k] = reference_localizer(v) }
    end

    #
    # @param [Object] datum
    # @return [Object]
    def reference_localizer(datum)
      case datum
      when Array
        reference_localizer_array(datum)
      when Hash
        reference_localizer_hash(datum)
      else
        datum
      end
    end

    #
    # @param [Prmd::SchemaHash] schemata
    # @return [Prmd::Schema]
    def combine(*schemata)
      # tracks which entities where defined in which file
      schemata_map = {}

      data = {}
      data.merge!(@base)
      data.merge!(@meta)

      schemata.each do |schema|
        id = schema.fetch('id')
        id_ary = id.split('/').last

        if s = schemata_map[id]
          $stderr.puts "`#{id}` (from #{schema.filename}) was already defined " \
                       "in `#{s.filename}` and will overwrite the first " \
                       "definition"
        end
        # avoinding damaging the original schema
        embedded_schema = schema.dup
        # schemas are now in a single scope by combine
        embedded_schema.delete('id')
        schemata_map[id] = embedded_schema

        data['definitions'][id_ary] = embedded_schema.to_h
        data['properties'][id_ary] = { '$ref' => "#/definitions/#{id_ary}" }

        reference_localizer(data['definitions'][id_ary])
      end

      Prmd::Schema.new(data)
    end

    private :reference_localizer_array
    private :reference_localizer_hash
    private :reference_localizer
  end
end
