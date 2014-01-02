module Prmd
  def self.combine(directory)
    # FIXME: where to get description/title from?
    #  "description":  "The direwolf API empowers developers to automate Heroku platform integration testing.",
    #  "title":        "Heroku Direwolf API",
    template = <<-SCHEMA_TEMPLATE
    {
      "definitions":  {
        <%- schemata.each do |key, schema| %>
        "<%= key %>": <%= schema %><%= ',' unless key == schemata.keys.last %>
        <%- end -%>
      },
      "properties":   {
        <%- schemata.each do |key, schema| %>
        "<%= key %>": { "$ref": "/definitions/<%= key %>" }<%= ',' unless key == schemata.keys.last %>
        <%- end -%>
      },
      "$schema":      "http://json-schema.org/draft-04/hyper-schema",
      "type":         ["object"]
    }
    SCHEMA_TEMPLATE

    schemata = {}

    Dir.glob(File.join(directory, '*.*')).each do |path|
      data = File.read(path)

      # rewrite to local json-references
      data.gsub!(%r{/schema/([^#]*)#}, '#/definitions/\1')
      data.gsub!(%r{%2Fschema%2F([^%]*)%23%2F}, '%23%2Fdefinitions%2F\1%2F')

      id = File.basename(path, '.json')

      schemata[id] = data
    end

    schema_path = 'schema.json'

    old_json = if File.exists?(schema_path)
      File.read(schema_path)
    else
      "{}"
    end

    schema = Erubis::Eruby.new(template).result({schemata: schemata})
    new_json = JSON.pretty_generate(JSON.parse(schema))
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
