module Prmd
  def self.combine(path, options={})
    unless File.directory?(path)
      data = JSON.parse(File.read(path))
    else
      data = {
        '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
        'definitions' => {},
        'properties'  => {},
        'type'        => ['object']
      }

      if options[:meta] && File.exists?(options[:meta])
        data.merge!(JSON.parse(File.read(options[:meta])))
      end

      Dir.glob(File.join(path, '**', '*.json')).each do |schema|
        schema_data = JSON.parse(File.read(schema))
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
    end

    Prmd::Schema.new(data)
  end
end
