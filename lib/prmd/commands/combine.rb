require 'forwardable'
require 'prmd/load_schema_file'

module Prmd
  class SchemaHash
    extend Forwardable

    attr_reader :filename
    def_delegator :@data, :[]
    def_delegator :@data, :[]=
    def_delegator :@data, :delete
    def_delegator :@data, :each

    def initialize(filename, data)
      @data = data
      @filename = filename
    end

    def fetch(key)
      @data.fetch(key) { abort "Missing key #{key} in #{filename}" }
    end

    def to_h
      @data.dup
    end
  end

  def self.combine(paths, options={})
    files = [*paths].map do |path|
      if File.directory?(path)
        Dir.glob(File.join(path, '**', '*.{json,yml,yaml}'))
      else
        path
      end
    end
    files.flatten!
    files.delete(options[:meta])

    # sort for stable loading on any platform
    schemata = []
    files.sort.each do |filename|
      begin
        schemata << SchemaHash.new(filename, load_schema_file(filename))
      rescue
        $stderr.puts "unable to parse #{filename}"
      end
    end
    unless schemata.length == files.length
      exit(1) # one or more files failed to parse
    end

    data = {
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'definitions' => {},
      'properties'  => {},
      'type'        => ['object']
    }

    # tracks which entities where defined in which file
    schemata_map = {}

    if options[:meta] && File.exists?(options[:meta])
      data.merge!(load_schema_file(options[:meta]))
    end

    reference_localizer = lambda do |datum|
      case datum
      when Array
        datum.map {|element| reference_localizer.call(element)}
      when Hash
        if datum.has_key?('$ref')
          datum['$ref'] = '#/definitions' + datum['$ref'].gsub('#', '').gsub('/schemata', '')
        end
        if datum.has_key?('href') && datum['href'].is_a?(String)
          datum['href'] = datum['href'].gsub('%23', '').gsub(%r{%2Fschemata(%2F[^%]*%2F)}, '%23%2Fdefinitions\1')
        end
        datum.each { |k,v| datum[k] = reference_localizer.call(v) }
      else
        datum
      end
    end

    schemata.each do |schema|
      id = schema.fetch('id')
      id_ary = id.split('/').last

      if s = schemata_map[id]
        $stderr.puts "`#{id}` (from #{schema.filename}) was already defined in `#{s.filename}` and will overwrite the first definition"
      end
      schemata_map[id] = schema

      # schemas are now in a single scope by combine
      schema.delete('id')

      data['definitions'][id_ary] = schema.to_h

      reference_localizer.call(data['definitions'][id_ary])

      data['properties'][id_ary] = { '$ref' => "#/definitions/#{id_ary}" }
    end

    Prmd::Schema.new(data)
  end
end
