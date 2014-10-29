require 'yaml'
require 'json'

# :nodoc:
module Prmd
  # Attempts to load either a json or yaml file, the type is determined by
  # filename extension.
  #
  # @param [String] filename
  # @return [Object] data
  def self.load_schema_file(filename)
    extname = File.extname(filename)
    File.open(filename) do |file|
      case extname.downcase
      when '.yaml', '.yml'
        result = YAML.load(file.read)
      when '.json'
        result = JSON.load(file.read)
      else
        abort "Cannot load schema file #{filename}" \
              "(unsupported file extension #{extname})"
      end
      abort "Cannot parse schema file #{filename}" if result.nil?
      result
    end
  end
end
