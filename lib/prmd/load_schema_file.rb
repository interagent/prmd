require 'yaml'
require 'json'

module Prmd
  def self.load_schema_file(filename)
    extname = File.extname(filename)
    File.open(filename) do |file|
      case extname.downcase
      when '.yaml', '.yml'
        YAML.load(file.read)
      when '.json'
        JSON.load(file.read)
      else
        abort "Cannot load schema file #{filename}" \
              "(unsupported file extension #{extname})"
      end
    end
  end
end
