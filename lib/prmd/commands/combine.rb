require 'prmd/load_schema_file'
require 'prmd/core/schema_hash'
require 'prmd/core/combiner'

module Prmd
  module Combine
    def self.handle_faulty_load(given, expected)
      unless given.size == expected.size
        abort 'Somes files have failed to parse. ' \
              'If you wish to continue without them,' \
              'please enable faulty_load using --faulty-load'
      end
    end

    def self.crawl_map(paths, options = {})
      files = [*paths].map do |path|
        if File.directory?(path)
          Dir.glob(File.join(path, '**', '*.{json,yml,yaml}'))
        else
          path
        end
      end
      files.flatten!
      files.delete(options[:meta])
      files
    end

    def self.load_schema_hash(filename)
      data = Prmd.load_schema_file(filename)
      SchemaHash.new(data, filename: filename)
    end

    def self.load_files(files, options = {})
      files.each_with_object([]) do |filename, result|
        begin
          result << load_schema_hash(filename)
        rescue JSON::ParserError, Psych::SyntaxError => ex
          $stderr.puts "unable to parse #{filename} (#{ex.inspect})"
        end
      end
    end

    def self.load_schemas(paths, options = {})
      files = crawl_map(paths, options)
      # sort for stable loading on any platform
      schemata = load_files(files.sort, options)
      handle_faulty_load(schemata, files) unless options[:faulty_load]
      schemata
    end

    def self.combine(paths, options = {})
      schemata = load_schemas(paths)
      base = Prmd::Template.load_json('combine_head.json')
      schema = base['$schema']
      meta = {}
      if options[:meta]
        meta = Prmd.load_schema_file(options[:meta])
      end
      combiner = Prmd::Combiner.new(meta: meta, base: base, schema: schema)
      combiner.combine(*schemata)
    end

    class << self
      private :handle_faulty_load
      private :crawl_map
      private :load_schema_hash
      private :load_files
      private :load_schemas
    end
  end

  def self.combine(paths, options = {})
    Combine.combine(paths, { faulty_load: false }.merge(options))
  end
end
