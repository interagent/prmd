require_relative 'loader'
require 'yaml'

module Prmd #:nodoc:
  module MultiLoader #:nodoc:
    # YAML MultiLoader
    module Yaml
      extend Prmd::MultiLoader::Loader

      # @see (Prmd::MultiLoader::Loader#load_data)
      def self.load_data(data)
        ::YAML.load(data)
      end

      # register this loader for all .yaml and .yml files
      extensions '.yaml', '.yml'
    end
  end
end
