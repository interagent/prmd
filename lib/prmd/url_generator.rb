require 'prmd/url_generators/generators/default'
require 'prmd/url_generators/generators/json'

module Prmd
  class UrlGenerator
    def initialize(params)
      @schema = params[:schema]
      @link = params[:link]
      @options = params[:options]
    end

    def url_params
      if @options[:doc][:url_style].downcase == 'json'
        klass = Generators::JSON
      else
        klass = Generators::Default
      end

      klass.generate(schema: @schema, link: @link)
    end
  end
end
