module Prmd
  def self.verify(schema)
    errors = []

    missing_requirements = []
    %w{description id $schema title type definitions links properties}.each do |requirement|
      unless schema.has_key?(requirement)
        missing_requirements << requirement
      end
    end
    unless missing_requirements.empty?
      errors << "schema missing fields: #{missing_requirements.join(', ')}"
    end

    if schema['definitions']
      unless schema['definitions'].has_key?('identity')
        errors << "definitions missing field: identity"
      end
      schema['definitions'].each do |key, value|
        missing_requirements = []
        %w{description readOnly type}.each do |requirement|
          unless schema['definitions'][key].has_key?(requirement)
            missing_requirements << requirement
          end
        end
        # check for example, unless they are nested in array/object
        type = schema['definitions'][key]['type']
        unless type.nil? || type.include?('array') || type.include?('object')
          unless schema['definitions'][key].has_key?('example')
            missing_requirements << 'example'
          end
        end
        unless missing_requirements.empty?
          errors << "`#{key}` definition missing fields: #{missing_requirements.join(', ')}"
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
        unless missing_requirements.empty?
          errors << "`#{link}` link missing fields: #{missing_requirements.join(', ')}"
        end
      end
    end

    errors
  end
end
