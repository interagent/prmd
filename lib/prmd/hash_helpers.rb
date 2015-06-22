# :nodoc:
module Prmd
  # Hash helper methods
  #
  # @api private
  module HashHelpers
    # Attempts to convert all keys in the hash to a Symbol.
    # This operation is recursive with subhashes
    #
    # @param [Hash] hash
    # @return [Hash]
    def self.deep_symbolize_keys(hash)
      deep_transform_keys(hash) do |key|
        if key.respond_to?(:to_sym)
          key.to_sym
        else
          key
        end
      end
    end

    # Think of this as hash.keys.map! { |key| }, that actually maps recursively.
    #
    # @param [Hash] hash
    # @return [Hash]
    # @yield [Object] key
    def self.deep_transform_keys(hash, &block)
      result = {}
      hash.each do |key, value|
        new_key = yield(key)
        new_value = value
        new_value = deep_transform_keys(value, &block) if value.is_a?(Hash)
        result[new_key] = new_value
      end
      result
    end
  end
end
