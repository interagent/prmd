module HashHelpers
  class << self
    def deep_symbolize_keys(hash)
      deep_transform_keys(hash){ |key| key.to_sym rescue key }
    end

    def deep_transform_keys(hash, &block)
      result = {}
      hash.each do |key, value|
        result[yield(key)] = value.is_a?(Hash) ? deep_transform_keys(value, &block) : value
      end
      result
    end
  end
end
