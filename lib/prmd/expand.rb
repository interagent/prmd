original = {
  'description' => 'A foo is bar.',
  'id'          => 'schema/foo',
  'title'       => 'API - Foo',

  'definitions' => {
    'created-at' => {
      'description' => 'when foo was created',
      'format'      => 'date-time'
    },
    'email' => {
      'description' => 'email for foo',
      'format'      => 'email'
    },
    'id' => {
      'description' => 'unique identifier for foo',
      'format'      => 'uuid'
    },
    'updated-at' => {
      'description' => 'when foo was created',
      'format'      => 'date-time',
      'type'        => ['null', 'string']
    }
  }
}
expanded = original.dup

errors = []

expanded = {
  '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
  'definitions' => {},
  'links'       => [],
  'properties'  => {},
  'type'        => ['object']
}.merge!(expanded)

missing_requirements = []
%w{description id $schema title type definitions links properties}.each do |requirement|
  unless expanded.has_key?(requirement)
    missing_requirements << requirement
  end
end
unless missing_requirements.empty?
  errors << "schema missing fields: #{missing_requirements.join(', ')}"
end

if original['definitions']
  original['definitions'].each do |key, value|
    default = case value['format']
    when 'uuid'
      {
        'example'   => '01234567-89ab-cdef-0123-456789abcdef',
        'readOnly'  => true,
        'type'      => ['string']
      }
    when 'email'
      {
        'example'   => 'username@example.com',
        'readOnly'  => false,
        'type'      => ['string']
      }
    when 'date-time'
      {
        'example'   => '2012-01-01T12:00:00Z',
        'readOnly'  => true,
        'type'      => ['string']
      }
    else
      {
        'readOnly'  => false
      }
    end

    expanded['definitions'][key] = default.merge!(value)

    missing_requirements = []
    %w{description example readOnly type}.each do |requirement|
      unless expanded['definitions'][key].has_key?(requirement)
        missing_requirements << requirement
      end
    end
    unless missing_requirements.empty?
       errors << "`#{key}` definition missing fields: #{missing_requirements.join(', ')}"
    end
  end
end

if original['links']
  original['links'].each do |key, value|
    default = case value['title']
    when 'Create'
      {
        'method'  => 'POST',
        'rel'     => 'create'
      }
    when 'Delete'
      {
        'method'  => 'DELETE',
        'rel'     => 'delete'
      }
    when 'Info'
      {
        'method'  => 'GET',
        'rel'     => 'self'
      }
    when 'List'
      {
        'method'  => 'GET',
        'rel'     => 'instances'
      }
    when 'Update'
      {
        'method'  => 'PATCH',
        'rel'     => 'update'
      }
    end

    missing_requirements = []
    %w{description href method rel title}.each do |requirement|
      unless expanded['links'][key].has_key?(requirement)
        missing_requirements << requirement
      end
    end
    unless missing_requirements.empty?
      errors << "`#{key}` link missing fields: #{missing_requirements.join(', ')}"
    end
  end
end


require 'json'
require 'pp'

puts

puts original_json = JSON.pretty_generate(original)
puts original_json.split("\n").length

puts

puts expanded_json = JSON.pretty_generate(expanded)
puts expanded_json.split("\n").length

puts

if errors.empty?
  puts("\e[32mNo schema errors detected.\e[0m")
else
  $stderr.puts("\e[31mErrors:\n#{errors.join("\n")}\e[0m")
end
