require 'erubis'
require 'json'

# :nodoc:
module Prmd
  # Template management
  #
  # @api private
  class Template
    @cache = {}

    # @return [String] location of the prmd templates directory
    def self.template_dirname
      File.join(File.dirname(__FILE__), 'templates')
    end

    # @param [String] args
    # @return [String] path in prmd's template directory
    def self.template_path(*args)
      File.expand_path(File.join(*args), template_dirname)
    end

    # Clear internal template cache
    #
    # @return [void]
    def self.clear_cache
      @cache.clear
    end

    # Attempts to load a template from the given path and base, if the template
    # was previously loaded, the cached template is returned instead
    #
    # @param [String] path
    # @param [String] base
    # @return [Erubis::Eruby] eruby template
    def self.load(path, base)
      @cache[[path, base]] ||= begin
        fallback = template_path

        resolved = File.join(base, path)
        unless File.exist?(resolved)
          resolved = File.join(fallback, path)
        end

        Erubis::Eruby.new(File.read(resolved), filename: resolved)
      end
    end

    #
    # @param [String] path
    # @param [String] base
    # @return (see .load)
    def self.load_template(path, base)
      load(path, base)
    end

    # Render a template given args or block.
    # args and block are passed to the template
    #
    # @param [String] path
    # @param [String] base
    # @return [String] result from template render
    def self.render(path, base, *args, &block)
      load_template(path, base).result(*args, &block)
    end

    # Load a JSON file from prmd's templates directory.
    # These files are not cached and are intended to be loaded on demand.
    #
    # @param [String] filename
    # @return [Object] data
    def self.load_json(filename)
      JSON.parse(File.read(template_path(filename)))
    end
  end
end
