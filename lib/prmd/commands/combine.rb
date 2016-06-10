require_relative '../load_schema_file'
require_relative '../core/schema_hash'
require_relative '../core/combiner'

# :nodoc:
module Prmd
  # Schema combine
  module Combine
    # @api private
    # @param [#size] given
    # @param [#size] expected
    # @return [void]
    def self.handle_faulty_load(given, expected)
      unless given.size == expected.size
        abort 'Somes files have failed to parse. ' \
              'If you wish to continue without them,' \
              'please enable faulty_load using --faulty-load'
      end
    end

    # @api private
    # @param [Array<String>] paths
    # @param [Hash<Symbol, Object>] options
    # @return [Array<String>] list of filenames from paths
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

    # @api private
    # @param [String] filename
    # @return [SchemaHash]
    def self.load_schema_hash(filename)
      data = Prmd.load_schema_file(filename)
      SchemaHash.new(data, filename: filename)
    end

    # @api private
    # @param [Array<String>] files
    # @param [Hash<Symbol, Object>] options
    # @return [Array<SchemaHash>] schema hashes
    def self.load_files(files, options = {})
      files.each_with_object([]) do |filename, result|
        begin
          result << load_schema_hash(filename)
        rescue JSON::ParserError, Psych::SyntaxError => ex
          $stderr.puts "unable to parse #{filename} (#{ex.inspect})"
        end
      end
    end

    # @api private
    # @param [Array<String>] paths
    # @param [Hash<Symbol, Object>] options
    # @return (see .load_files)
    def self.load_schemas(paths, options = {})
      files = crawl_map(paths, options)
      # sort for stable loading across platforms
      schemata = load_files(files.sort, options)
      handle_faulty_load(schemata, files) unless options[:faulty_load]
      schemata
    end

    # Escape '#' and '/' in 'href' keys. They need to be escaped in JSON schema,
    # but to make it easier to write JSON schema with Prmd, those two characters
    # are escaped automatically when they appear between '{()}'.
    # See https://github.com/interagent/prmd/issues/106.
    #
    # @api private
    # @param [Array<SchemaHash>] schema hashes
    # @return [Array<SchemaHash>] schema hashes
    def self.escape_hrefs(data)
      if data.is_a? Array
        data.map! {
          |x| escape_hrefs(x)
        }
      elsif data.is_a?(Hash) || data.is_a?(Prmd::SchemaHash)
        data.each { |k,v|
          if k == 'href'
            if v.is_a? String
              v = v.gsub(/\{\(.*?\)\}/) { |x|
                x.gsub('#', '%23').gsub('/', '%2F')
              }
            end
          else
            v = escape_hrefs(v)
          end
          data[k] = v
        }
      end
      data
    end

    # Merges all found schema files in the given paths into a single Schema
    #
    # @param [Array<String>] paths
    # @param [Hash<Symbol, Object>] options
    # @return (see Prmd::Combiner#combine)
    def self.combine(paths, options = {})
      schemata = escape_hrefs(load_schemas(paths))
      base = Prmd::Template.load_json('combine_head.json')
      schema = base['$schema']
      meta = {}
      filename = options[:meta]
      meta = Prmd.load_schema_file(filename) if filename
      if meta.nil? || meta.empty?
        if filename
          warn "Meta file (#{filename}) is empty, please fill it next time."
        else
          warn "Meta is empty, please fill it next time."
        end
        meta ||= {}
      end
      combiner = Prmd::Combiner.new(meta: meta, base: base, schema: schema, options: options)
      combiner.combine(*schemata)
    end

    class << self
      private :handle_faulty_load
      private :crawl_map
      private :load_schema_hash
      private :load_files
      private :load_schemas
      private :escape_hrefs
    end
  end

  # (see Prmd::Combine.combine)
  def self.combine(paths, options = {})
    Combine.combine(paths, { faulty_load: false }.merge(options))
  end
end
