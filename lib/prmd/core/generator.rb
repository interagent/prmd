require 'json'
require 'prmd/schema'

module Prmd
  class Generator
    def initialize(properties = {})
      @properties = properties
      @base = properties.fetch(:base, {})
      @template = properties.fetch(:template)
    end

    def generate(options = {})
      res = @template.result(options)
      resource_schema = JSON.parse(res)
      schema = Prmd::Schema.new
      schema.merge!(@base)
      schema.merge!(resource_schema)
      schema
    end
  end
end
