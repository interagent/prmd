require 'cgi'

# :nodoc:
module Prmd
  # :nodoc:
  class UrlGenerator
    # :nodoc:
    module Generators
      # JSON URL Generator
      #
      # @api private
      class JSON
        # @param [Hash<Symbol, Object>] params
        def self.generate(params)
          data = {}
          data.merge!(params[:schema].schema_example(params[:link]['schema']))

          result = []
          data.sort_by {|k,_| k.to_s }.each do |key, values|
            [values].flatten.each do |value|
              result << [key.to_s, CGI.escape(value.to_s)].join('=')
            end
          end

          result
        end
      end
    end
  end
end
