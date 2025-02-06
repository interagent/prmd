require_relative "url_generators/generators/default"
require_relative "url_generators/generators/json"

# :nodoc:
module Prmd
  # Schema URL Generation
  # @api private
  class UrlGenerator
    # @param [Hash<Symbol, Object>] params
    def initialize(params)
      @schema = params[:schema]
      @link = params[:link]
      @options = params.fetch(:options)
    end

    # @return [Array]
    def url_params
      klass = if @options[:doc][:url_style].downcase == "json"
        Generators::JSON
      else
        Generators::Default
      end

      klass.generate(schema: @schema, link: @link)
    end
  end
end
