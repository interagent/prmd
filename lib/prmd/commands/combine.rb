module Prmd
  def self.combine(path, options={})
    files = if File.directory?(path)
      Dir.glob(File.join(path, '**', '*.json')) +
        Dir.glob(File.join(path, '**', '*.yaml')) -
        [options[:meta]]
    else
      [path]
    end
    # sort for stable loading on any platform
    schemata = files.sort.map { |file| [file, YAML.load(File.read(file))] }

    data = {
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'definitions' => {},
      'properties'  => {},
      'type'        => ['object']
    }

    # tracks which entities where defined in which file
    schemata_map = {}

    if options[:meta] && File.exists?(options[:meta])
      data.merge!(YAML.load(File.read(options[:meta])))
    end

    schemata.each do |schema_file, schema_data|
      id = schema_data['id'].split('/').last

      if file = schemata_map[schema_data['id']]
        $stderr.puts "`#{schema_data['id']}` (from #{schema_file}) was already defined in `#{file}` and will overwrite the first definition"
      end
      schemata_map[schema_data['id']] = schema_file

      # schemas are now in a single scope by combine
      schema_data.delete('id')

      data['definitions']
      data['definitions'][id] = schema_data
      reference_localizer = lambda do |datum|
        case datum
        when Array
          datum.map {|element| reference_localizer.call(element)}
        when Hash
          if datum.has_key?('$ref')
            datum['$ref'] = '#/definitions' + datum['$ref'].gsub('#', '').gsub('/schemata', '')
          end
          if datum.has_key?('href')
            datum['href'] = datum['href'].gsub('%23', '').gsub(%r{%2Fschemata(%2F[^%]*%2F)}, '%23%2Fdefinitions\1')
          end
          datum.each { |k,v| datum[k] = reference_localizer.call(v) }
        else
          datum
        end
      end
      reference_localizer.call(data['definitions'][id])

      data['properties'][id] = { '$ref' => "#/definitions/#{id}" }
    end

    Prmd::Schema.new(data)
  end
end
