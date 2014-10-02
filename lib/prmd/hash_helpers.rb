# :nodoc:
module Prmd
  module HashHelpers
    def self.deep_symbolize_keys(hash)
      deep_transform_keys(hash) do |key|
        if key.respond_to?(:to_sym)
          key.to_sym
        else
          key
        end
      end
    end

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
