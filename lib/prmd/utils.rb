module Prmd
  # For any tid bits, or core extension methods, without the "core" extension
  module Utils
    # For checking if the string contains only spaces
    BLANK_REGEX = /\A\s+\z/

    def self.blank?(obj)
      if obj.nil?
        true
      elsif obj.is_a?(String)
        obj.empty? || !!(obj =~ BLANK_REGEX)
      elsif obj.respond_to?(:empty?)
        obj.empty?
      else
        false
      end
    end
  end
end
