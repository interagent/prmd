require 'erubis'

module Prmd
  class Template
    @cache = {}

    def self.template_dirname
      File.join(File.dirname(__FILE__), 'templates')
    end

    def self.template_path(*args)
      File.expand_path(File.join(*args), template_dirname)
    end

    def self.clear_cache
      @cache.clear
    end

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

    def self.load_template(path, base)
      load(path, base)
    end

    def self.render(path, base, *args, &block)
      load_template(path, base).result(*args, &block)
    end

    def self.load_json(filename)
      JSON.parse(File.read(template_path(filename)))
    end
  end
end
