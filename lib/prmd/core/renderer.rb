require_relative '../template'

# :nodoc:
module Prmd
  # Schema Generator
  class Renderer
    #
    # @param [Hash<Symbol, Object>] properties
    def initialize(properties = {})
      @properties = properties
      @template = @properties.fetch(:template)
    end

    #
    # @return [Hash<Symbol, Object>]
    def default_options
      {
        http_header: {},
        content_type: 'application/json',
        doc: {},
        prepend: nil
      }
    end

    #
    # @param [Hash<Symbol, Object>] options
    # @return [void]
    def append_default_options(options)
      options[:doc] = {
        url_style: 'default',
        disable_title_and_description: false,
        toc: false
      }.merge(options[:doc])
    end

    #
    # @param [Hash<Symbol, Object>] options
    # @return [Hash<Symbol, Object>]
    def setup_options(options)
      opts = default_options
      opts.merge!(options)
      append_default_options(opts)
      opts
    end

    #
    # @param [Prmd::Schema] schema
    # @param [Hash<Symbol, Object>] options
    def render(schema, options = {})
      @template.result(schema: schema, options: setup_options(options))
    end

    private :default_options
    private :append_default_options
    private :setup_options
  end
end
