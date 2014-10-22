require 'cgi'

# :nodoc:
module Prmd
  # :nodoc:
  class UrlGenerator
    # :nodoc:
    module Generators
      # Default URL Generator
      #
      # @api private
      class Default
        # @param [Hash<Symbol, Object>] params
        def self.generate(params)
          data = {}
          data.merge!(params[:schema].schema_example(params[:link]['schema']))
          generate_params(data)
        end

        # @param [String] key
        # @param [String] prefix
        # @return [String]
        def self.param_name(key, prefix, array = false)
          result = if prefix
            "#{prefix}[#{key}]"
          else
            key
          end

          result += '[]' if array
          result
        end

        # @param [Hash] obj
        # @param [String] prefix
        # @return [String]
        def self.generate_params(obj, prefix = nil)
          result = []
          obj.each do |key,value|
            if value.is_a?(Hash)
              newprefix = if prefix
                "#{prefix}[#{key}]"
              else
                key
              end
              result << generate_params(value, newprefix)
            elsif value.is_a?(Array)
              value.each do |val|
                result << [param_name(key, prefix, true), CGI.escape(val.to_s)].join('=')
              end
            else
              next unless value # ignores parameters with empty examples
              result << [param_name(key, prefix), CGI.escape(value.to_s)].join('=')
            end
          end
          result.flatten
        end

        class << self
          private :param_name
          private :generate_params
        end
      end
    end
  end
end
