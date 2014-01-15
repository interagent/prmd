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
      schema['definitions'].each do |key, value|
        missing_requirements = []
        %w{description example readOnly type}.each do |requirement|
          unless schema['definitions'][key].has_key?(requirement)
            missing_requirements << requirement
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

    if errors.empty?
      puts("\e[32mNo schema errors detected.\e[0m")
    else
      $stderr.puts("\e[31mErrors:\n#{errors.join("\n")}\e[0m")
    end
  end
end
