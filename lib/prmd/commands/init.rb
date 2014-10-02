require 'json'
require 'prmd/template'

module Prmd
  def self.init(resource, options = {})
    data = Prmd::Template.load_json('init_default.json')

    schema = Prmd::Schema.new(data)

    if resource
      if resource.include?('/')
        parent, resource = resource.split('/')
      end
      res = Prmd::Template.render('init_resource.json.erb', '',
                                  resource: resource, parent: parent)
      resource_schema = JSON.parse(res)
      schema.merge!(resource_schema)
    end

    if options[:yaml]
      schema.to_yaml
    else
      schema.to_json
    end
  end
end
