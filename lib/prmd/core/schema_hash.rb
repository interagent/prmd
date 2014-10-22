require 'forwardable'

# :nodoc:
module Prmd
  # Specialized Hash for handling loaded Schema data
  class SchemaHash
    extend Forwardable

    # @return [Hash]
    attr_reader :data
    # @return [String]
    attr_reader :filename

    def_delegator :@data, :[]
    def_delegator :@data, :[]=
    def_delegator :@data, :delete
    def_delegator :@data, :each

    # @param [Hash] data
    # @param [Hash<Symbol, Object>] options
    def initialize(data, options = {})
      @data = data
      @filename = options.fetch(:filename, '')
    end

    # @param [Prmd::SchemaHash] other
    # @return [self]
    def initialize_copy(other)
      super
      @data = other.data.dup
      @filename = other.filename.dup
    end

    # @param [String] key
    # @return [self]
    def fetch(key)
      @data.fetch(key) { abort "Missing key #{key} in #{filename}" }
    end

    # @return [Hash]
    def to_h
      @data.dup
    end

    protected :data
  end
end
