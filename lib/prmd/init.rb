module Prmd
  def self.init(path, resource)
    schema = {
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'definitions' => {},
      'links'       => [],
      'properties'  => {},
      'type'        => ['object']
    }

    if resource
      schema['id']    = "schema/#{resource}"
      schema['title'] = "... - #{resource[0...1].upcase}#{resource[1..-1]}"
      schema['links'] = [
        {
          "description" => "Create a new #{resource}.",
          "method"      => "POST",
          "rel"         => "create",
          "title"       => "Create"
        },
        {
          "description" => "Delete an existing #{resource}.",
          "method"      => "DELETE",
          "rel"         => "destroy",
          "title"       => "Delete"
        },
        {
          "description"  => "Info for existing #{resource}.",
          "method"       => "GET",
          "rel"          => "self",
          "title"        => "Info"
        },
        {
          "description"  => "List existing #{resource}.",
          "method"       => "GET",
          "rel"          => "instances",
          "title"        => "List"
        },
        {
          "description"  => "Update an existing #{resource}.",
          "method"       => "PATCH",
          "rel"          => "update",
          "title"        => "Update"
        }
      ]
      # ensure meta properties are at the top and otherwise alpha sorted keys
      def schema.keys
        ['$schema', 'id', 'title', 'type', 'definitions', 'links', 'properties']
      end
    else
      # ensure meta properties are at the top and otherwise alpha sorted keys
      def schema.keys
        ['$schema', 'type', 'definitions', 'links', 'properties']
      end
    end

    File.open(path, 'w') do |file|
      file.write(JSON.pretty_generate(schema))
    end
  end
end
