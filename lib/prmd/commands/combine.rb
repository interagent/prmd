module Prmd
  def self.combine(directory)
    template = <<-SCHEMA_TEMPLATE
    {
      "definitions":  {
        <%- schemata.each do |key, schema| %>
        "<%= key %>": <%= schema %><%= ',' unless key == schemata.keys.last %>
        <%- end -%>
      },
      "properties":   {
        <%- schemata.each do |key, schema| %>
        "<%= key %>": { "$ref": "#/definitions/<%= key %>" }<%= ',' unless key == schemata.keys.last %>
        <%- end -%>
      },
      "$schema":      "http://json-schema.org/draft-04/hyper-schema",
      "type":         ["object"]
    }
    SCHEMA_TEMPLATE

    schemata = {}

    Dir.glob(File.join(directory, '**', '*.json')).each do |path|
      id = File.basename(path, '.json')
      next if id[0] == "_"

      data = File.read(path)

      # rewrite to local json-references
      data.gsub!(%r{/schema/([^#]*)#}, '#/definitions/\1')
      data.gsub!(%r{%2Fschema%2F([^%]*)%23%2F}, '%23%2Fdefinitions%2F\1%2F')

      schemata[id] = data
    end

    schema_path = 'schema.json'

    old_json = if File.exists?(schema_path)
      File.read(schema_path)
    else
      "{}"
    end

    schema = JSON.parse(Erubis::Eruby.new(template).result({schemata: schemata}))

    meta_path = File.join(directory, '_meta.json')
    if File.exists?(meta_path)
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      schema.merge!(JSON.parse(File.read(meta_path)), &merger)
    end

    new_json = JSON.pretty_generate(schema)
    # nuke empty lines
    new_json = new_json.split("\n").delete_if {|line| line.empty?}.join("\n")
    File.open(schema_path, 'w') do |file|
      file.write(new_json)
    end

    old_lines = old_json.split("\n")
    Diff::LCS.diff(old_lines, new_json.split("\n")).each do |diff|
      puts "#{diff.first.position}..#{diff.last.position}"
      diff.each do |change|
        puts "#{change.action} #{change.element}"
      end
    end
  end
end
