require 'prmd/template'

module Prmd
  class Renderer
    def initialize(properties = {})
      @properties = properties
      @template = @properties.fetch(:template)
    end

    def default_options
      {
        http_header: {},
        content_type: 'application/json',
        doc: {},
        prepend: nil
      }
    end

    def append_default_options(options)
      options[:doc] = {
        url_style: 'default',
        disable_title_and_description: false
      }.merge(options[:doc])
    end

    def setup_options(options)
      opts = default_options
      opts.merge!(options)
      append_default_options(opts)
      opts
    end

    def render(schema, options = {})
      @template.result(schema: schema, options: setup_options(options))
    end

    private :default_options
    private :append_default_options
    private :setup_options
  end
end
