module Prmd
  class Template
    @cache = {}

    def self.clear_cache
      @cache.clear
    end

    def self.load(path, base)
      @cache[[path, base]] ||= begin
        fallback = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

        resolved = File.join(base, path)
        if not File.exist?(resolved)
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
  end
end
