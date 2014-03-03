module Prmd
  def self.init(path, resource)
    schema = Prmd::Schema.new
    schema.data.merge!({
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'title'       => '...',
      'type'        => ['object'],
      'definitions' => {},
      'links'       => [],
      'properties'  => {}
    })

    meta_path = File.join(File.basename(path), '_meta.json')
    if File.exists?(meta_path)
      schema.data.merge!(JSON.parse(File.read(meta_path)))
    end

    if resource
      schema.data['id']    = "schema/#{resource}"
      schema.data['title'] = "#{schema.data['title']} - #{resource[0...1].upcase}#{resource[1..-1]}"
      schema.data['definitions'] = {
        "created_at" => {
          "description" => "when #{resource} was created",
          "example"     => "2012-01-01T12:00:00Z",
          "format"      => "date-time",
          "readOnly"    => true,
          "type"        => ["string"]
        },
        "id" => {
          "description" => "unique identifier of #{resource}",
          "example"     => "01234567-89ab-cdef-0123-456789abcdef",
          "format"      => "uuid",
          "readOnly"    => true,
          "type"        => ["string"]
        },
        "identity" => {
          "$ref" => "/schema/#{resource}#/definitions/id"
        },
        "updated_at" => {
          "description" => "when #{resource} was updated",
          "example"     => "2012-01-01T12:00:00Z",
          "format"      => "date-time",
          "readOnly"    => true,
          "type"        => ["string"]
        }
      }
      schema.data['links'] = [
        {
          "description" => "Create a new #{resource}.",
          "href"        => "/#{resource}s",
          "method"      => "POST",
          "rel"         => "create",
          "title"       => "Create"
        },
        {
          "description" => "Delete an existing #{resource}.",
          "href"        => "/#{resource}s/{(%2Fschema%2F#{resource}%23%2Fdefinitions%2Fidentity)}",
          "method"      => "DELETE",
          "rel"         => "destroy",
          "title"       => "Delete"
        },
        {
          "description"  => "Info for existing #{resource}.",
          "href"        => "/#{resource}s/{(%2Fschema%2F#{resource}%23%2Fdefinitions%2Fidentity)}",
          "method"       => "GET",
          "rel"          => "self",
          "title"        => "Info"
        },
        {
          "description"  => "List existing #{resource}.",
          "href"        => "/#{resource}s",
          "method"       => "GET",
          "rel"          => "instances",
          "title"        => "List"
        },
        {
          "description"  => "Update an existing #{resource}.",
          "href"        => "/#{resource}s/{(%2Fschema%2F#{resource}%23%2Fdefinitions%2Fidentity)}",
          "method"       => "PATCH",
          "rel"          => "update",
          "title"        => "Update"
        }
      ]
      schema.data['properties'] = {
        "created_at"  => { "$ref" => "/schema/#{resource}#/definitions/created_at" },
        "id"          => { "$ref" => "/schema/#{resource}#/definitions/id" },
        "updated_at"  => { "$ref" => "/schema/#{resource}#/definitions/updated_at" }
      }
    end

    File.open(path, 'w') do |file|
      file.write(schema.to_s)
    end
  end
end
