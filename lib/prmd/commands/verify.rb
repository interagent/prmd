require "json"
require "json_schema"

module Prmd
  # These schemas are listed manually and in order because they reference each
  # other.
  SCHEMAS = [
    "schema.json",
    "hyper-schema.json",
    "interagent-hyper-schema.json"
  ]

  def self.verify(schema_data)
    store = init_document_store

    if !(schema_uri = schema_data["$schema"])
      return ["Missing $schema."]
    end

    # for good measure, make sure that the schema parses and that its
    # references can be expanded
    schema, errors = JsonSchema.parse!(schema_data)
    return JsonSchema::SchemaError.aggregate(errors) if !schema

    valid, errors = schema.expand_references(store: store)
    return JsonSchema::SchemaError.aggregate(errors) if !valid

    if !(meta_schema = store.lookup_schema(schema_uri))
      return ["Unknown $schema: #{schema_uri}."]
    end

    valid, errors = meta_schema.validate(schema_data)
    return JsonSchema::SchemaError.aggregate(errors) if !valid

    []
  end

  private

  def self.init_document_store
    store = JsonSchema::DocumentStore.new
    SCHEMAS.each do |file|
      file = File.expand_path("../../../../schemas/#{file}", __FILE__)
      data = JSON.parse(File.read(file))
      schema = JsonSchema::Parser.new.parse!(data)
      schema.expand_references!(store: store)
      store.add_schema(schema)
    end
    store
  end
end
