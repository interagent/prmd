module Prmd
  class Template
    def self.load(path, base)
      fallback = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      resolved = File.join(base, path)
      if not File.exist?(resolved)
        resolved = File.join(fallback, path)
      end

      return File.read(resolved)
    end

    def self.render(path, base, *args)
      template = self.load(path, base)
      Erubis::Eruby.new(template).result(*args)
    end
  end
end
