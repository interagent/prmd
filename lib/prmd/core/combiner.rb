require_relative '../schema'
require_relative 'schema_hash'
require_relative 'reference_localizer'

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
      @options = properties.fetch(:options, {})
    end

    # @param [Object] datum
    # @return [Object]
    def reference_localizer(datum)
      ReferenceLocalizer.localize(datum)
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

      Prmd::Schema.new(data, @options)
    end

    private :reference_localizer
  end
end
