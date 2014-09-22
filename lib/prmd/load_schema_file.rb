module Prmd
  def self.load_schema_file(filename)
    data = File.read(filename)
    extname = File.extname(filename)

    case extname.downcase
    when ".yaml", ".yml"
      YAML.load(data)
    when ".json"
      JSON.load(data)
    else
      abort "Cannot load schema file #{filename}, (unsupported file extension #{extname})"
    end
  end
end
