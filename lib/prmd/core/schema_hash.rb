require 'forwardable'

module Prmd
  class SchemaHash
    extend Forwardable

    attr_reader :data
    attr_reader :filename
    def_delegator :@data, :[]
    def_delegator :@data, :[]=
    def_delegator :@data, :delete
    def_delegator :@data, :each

    def initialize(data, options = {})
      @data = data
      @filename = options.fetch(:filename, '')
    end

    def initialize_copy(other)
      super
      @data = other.data.dup
      @filename = other.filename.dup
    end

    def fetch(key)
      @data.fetch(key) { abort "Missing key #{key} in #{filename}" }
    end

    def to_h
      @data.dup
    end

    protected :data
  end
end
