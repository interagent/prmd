require 'json'
require 'json_schema'

# :nodoc:
module Prmd
  # Schema Verification
  module Verification
    # These schemas are listed manually and in order because they reference each
    # other.
    SCHEMAS = [
      'schema.json',
      'hyper-schema.json',
      'interagent-hyper-schema.json'
    ]

    # @return [JsonSchema::DocumentStore]
    def self.init_document_store
      store = JsonSchema::DocumentStore.new
      SCHEMAS.each do |file|
        file = File.expand_path("../../../../schemas/#{file}", __FILE__)
        add_schema(store, file)
      end
      add_schema(store, @custom_schema) unless @custom_schema.nil?
      store
    end

    def self.add_schema(store, file)
      data = JSON.parse(File.read(file))
      schema = JsonSchema::Parser.new.parse!(data)
      schema.expand_references!(store: store)
      store.add_schema(schema)
    end

    # @return [JsonSchema::DocumentStore]
    def self.document_store
      @document_store ||= init_document_store
    end

    # @param [Hash] schema_data
    # @return [Array<String>] errors from failed verfication
    def self.verify_parsable(schema_data)
      # for good measure, make sure that the schema parses and that its
      # references can be expanded
      schema, errors = JsonSchema.parse!(schema_data)
      return JsonSchema::SchemaError.aggregate(errors) unless schema

      valid, errors = schema.expand_references(store: document_store)
      return JsonSchema::SchemaError.aggregate(errors) unless valid

      []
    end

    # @param [Hash] schema_data
    # @return [Array<String>] errors from failed verfication
    def self.verify_meta_schema(meta_schema, schema_data)
      valid, errors = meta_schema.validate(schema_data)
      return JsonSchema::SchemaError.aggregate(errors) unless valid

      []
    end

    # @param [Hash] schema_data
    # @return [Array<String>] errors from failed verfication
    def self.verify_schema(schema_data)
      schema_uri = schema_data['$schema']
      return ['Missing $schema key.'] unless schema_uri

      meta_schema = document_store.lookup_schema(schema_uri)
      return ["Unknown $schema: #{schema_uri}."] unless meta_schema

      verify_meta_schema(meta_schema, schema_data)
    end

    # Verfies that a given schema is valid
    #
    # @param [Hash] schema_data
    # @return [Array<String>] errors from failed verification
    def self.verify(schema_data, custom_schema: nil)
      @custom_schema = custom_schema
      a = verify_schema(schema_data)
      return a unless a.empty?
      b = verify_parsable(schema_data)
      return b unless b.empty?
      []
    end

    class << self
      private :init_document_store
      private :document_store
      private :verify_parsable
      private :verify_schema
      private :verify_meta_schema
    end
  end

  # (see Prmd::Verification.verify)
  def self.verify(schema_data, custom_schema: nil)
    Verification.verify(schema_data, custom_schema: custom_schema)
  end
end
