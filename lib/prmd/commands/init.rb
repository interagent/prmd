module Prmd
  def self.init(resource, options={})
    data = {
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'title'       => 'FIXME',
      'definitions' => {},
      'description' => 'FIXME',
      'links'       => [],
      'properties'  => {},
      'type'        => ['object']
    }

    schema = Prmd::Schema.new(data)

    if resource
      if resource.include?('/')
        parent, resource = resource.split('/')
      end
      schema['id']    = "schema/#{resource}"
      schema['title'] = "FIXME - #{resource[0...1].upcase}#{resource[1..-1]}"
      schema['definitions'] = {
        "created_at" => {
          "description" => "when #{resource} was created",
          "example"     => "2012-01-01T12:00:00Z",
          "format"      => "date-time",
          "type"        => ["string"]
        },
        "id" => {
          "description" => "unique identifier of #{resource}",
          "example"     => "01234567-89ab-cdef-0123-456789abcdef",
          "format"      => "uuid",
          "type"        => ["string"]
        },
        "identity" => {
          "$ref" => "/schemata/#{resource}#/definitions/id"
        },
        "updated_at" => {
          "description" => "when #{resource} was updated",
          "example"     => "2012-01-01T12:00:00Z",
          "format"      => "date-time",
          "type"        => ["string"]
        }
      }
      schema['links'] = [
        {
          "description"   => "Create a new #{resource}.",
          "href"          => "/#{resource}s",
          "method"        => "POST",
          "rel"           => "create",
          "schema"        => {
            "properties"  => {},
            "type"        => ["object"]
          },
          "title"         => "Create"
        },
        {
          "description"   => "Delete an existing #{resource}.",
          "href"          => "/#{resource}s/{(%2Fschemata%2F#{resource}%23%2Fdefinitions%2Fidentity)}",
          "method"        => "DELETE",
          "rel"           => "destroy",
          "title"         => "Delete"
        },
        {
          "description"   => "Info for existing #{resource}.",
          "href"          => "/#{resource}s/{(%2Fschemata%2F#{resource}%23%2Fdefinitions%2Fidentity)}",
          "method"        => "GET",
          "rel"           => "self",
          "title"         => "Info"
        },
        {
          "description"   => "List existing #{resource}s.",
          "href"          => "/#{resource}s",
          "method"        => "GET",
          "rel"           => "instances",
          "title"         => "List"
        },
        {
          "description"   => "Update an existing #{resource}.",
          "href"          => "/#{resource}s/{(%2Fschemata%2F#{resource}%23%2Fdefinitions%2Fidentity)}",
          "method"        => "PATCH",
          "rel"           => "update",
          "schema"        => {
            "properties"  => {},
            "type"        => ["object"]
          },
          "title"         => "Update"
        }
      ]
      if parent
        schema['links'] << {
          "description"  => "List existing #{resource}s for existing #{parent}.",
          "href"         => "/#{parent}s/{(%2Fschemata%2F#{parent}%23%2Fdefinitions%2Fidentity)}/#{resource}s",
          "method"       => "GET",
          "rel"          => "instances",
          "title"        => "List"
        }
      end
      schema['properties'] = {
        "created_at"  => { "$ref" => "/schemata/#{resource}#/definitions/created_at" },
        "id"          => { "$ref" => "/schemata/#{resource}#/definitions/id" },
        "updated_at"  => { "$ref" => "/schemata/#{resource}#/definitions/updated_at" }
      }
    end

    if options[:yaml]
      schema.to_yaml
    else
      schema.to_json
    end
  end
end
