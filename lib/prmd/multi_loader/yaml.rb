require_relative "loader"
require "yaml"

module Prmd # :nodoc:
  module MultiLoader # :nodoc:
    # YAML MultiLoader
    module Yaml
      extend Prmd::MultiLoader::Loader

      # @see (Prmd::MultiLoader::Loader#load_data)
      def self.load_data(data)
        if ::YAML.respond_to?(:unsafe_load)
          ::YAML.unsafe_load(data)
        else
          ::YAML.load(data)
        end
      end

      # register this loader for all .yaml and .yml files
      extensions ".yaml", ".yml"
    end
  end
end
