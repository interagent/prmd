class Hash
  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym rescue key }
  end

  def deep_transform_keys(&block)
    result = {}
    each do |key, value|
      result[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys(&block) : value
    end
    result
  end
end
