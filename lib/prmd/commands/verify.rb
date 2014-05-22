module Prmd
  def self.verify(schema)
    errors = []
    errors << verify_schema(schema)
    schema = Prmd::Schema.new(schema)
    if schema['properties']
      schema['properties'].each do |key, value|
        _, schemata = schema.dereference(value)
        errors << verify_schema(schemata)
        errors << verify_definitions_and_links(schemata)
      end
    end
    errors.flatten!
  end

  def self.verify_schema(schema)
    errors = []

    id = schema['id']

    missing_requirements = []
    %w{$schema definitions description links properties title type}.each do |requirement|
      unless schema.has_key?(requirement)
        missing_requirements << requirement
      end
    end
    missing_requirements.each do |missing_requirement|
      errors << "Missing `#{id}#/#{missing_requirement}`"
    end

    errors
  end

  def self.verify_definitions_and_links(schema)
    errors = []

    id = schema['id']

    if schema['definitions']
      unless schema['definitions'].has_key?('identity')
        errors << "Missing `#{id}#/definitions/identity`"
      end
      schema['definitions'].each do |key, value|
        missing_requirements = []
        unless key == 'identity'
          %w{description type}.each do |requirement|
            unless schema['definitions'][key].has_key?(requirement)
              missing_requirements << requirement
            end
          end
        end
        # check for example, unless they are nested in array/object
        type = schema['definitions'][key]['type']
        unless type.nil? || type.include?('array') || type.include?('object')
          unless schema['definitions'][key].has_key?('example')
            missing_requirements << 'example'
          end
        end
        missing_requirements.each do |missing_requirement|
          errors << "Missing `#{id}#/definitions/#{key}/#{missing_requirement}`"
        end
      end
    end

    if schema['links']
      schema['links'].each do |link|
        missing_requirements = []
        %w{description href method rel title}.each do |requirement|
          unless link.has_key?(requirement)
            missing_requirements << requirement
          end
        end
        if link.has_key?('schema')
          %w{properties type}.each do |requirement|
            unless link['schema'].has_key?(requirement)
              missing_requirements << "schema/#{requirement}"
            end
          end
        end
        missing_requirements.each do |missing_requirement|
          errors << "Missing #{missing_requirement} in `#{link}` link for `#{id}`"
        end
      end
    else
      errors << "Missing `#{id}/links`"
    end

    errors
  end
end
