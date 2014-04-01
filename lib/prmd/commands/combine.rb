module Prmd
  def self.combine(path, options={})
    files = if File.directory?(path)
      Dir.glob(File.join(path, '**', '*.json')) - [options[:meta]]
    else
      [path]
    end
    schemas = files.map { |file| JSON.parse(File.read(file)) }

    data = {
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'definitions' => {},
      'properties'  => {},
      'type'        => ['object']
    }

    if options[:meta] && File.exists?(options[:meta])
      data.merge!(JSON.parse(File.read(options[:meta])))
    end

    schemas.each do |schema_data|
      id = if schema_data['id']
        schema_data['id'].gsub('schema/', '')
      end
      next if id.nil? || id[0..0] == '_' # FIXME: remove this exception?

      data['definitions'][id] = schema_data
      reference_localizer = lambda do |datum|
        case datum
        when Array
          datum.map {|element| reference_localizer.call(element)}
        when Hash
          if datum.has_key?('$ref')
            datum['$ref'] = datum['$ref'].gsub(%r{/schema/([^#]*)#}, '#/definitions/\1')
          end
          if datum.has_key?('href')
            datum['href'] = datum['href'].gsub(%r{%2Fschema%2F([^%]*)%23%2F}, '%23%2Fdefinitions%2F\1%2F')
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
