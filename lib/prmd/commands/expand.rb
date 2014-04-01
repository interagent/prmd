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

expanded = {
  '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
  'definitions' => {},
  'links'       => [],
  'properties'  => {},
  'type'        => ['object']
}.merge!(expanded)

if original['definitions']
  original['definitions'].each do |key, value|
    default = case value['format']
    when 'uuid'
      {
        'example'   => '01234567-89ab-cdef-0123-456789abcdef',
        'type'      => ['string']
      }
    when 'email'
      {
        'example'   => 'username@example.com',
        'type'      => ['string']
      }
    when 'date-time'
      {
        'example'   => '2012-01-01T12:00:00Z',
        'type'      => ['string']
      }
    else
      {}
    end
    expanded['definitions'][key] = default.merge!(value)
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
    expanded = original['links'][key] = default.merge!(value)
  end
end


#require 'json'
#require 'pp'

#puts

#puts original_json = JSON.pretty_generate(original)
#puts original_json.split("\n").length

#puts

#puts expanded_json = JSON.pretty_generate(expanded)
#puts expanded_json.split("\n").length

#puts
