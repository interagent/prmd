require_relative 'loader'
require 'toml'

module Prmd #:nodoc:
  module MultiLoader #:nodoc:
    # TOML MultiLoader
    module Toml
      extend Prmd::MultiLoader::Loader

      # @see (Prmd::MultiLoader::Loader#load_data)
      def self.load_data(data)
        ::TOML.load(data)
      end

      # register this loader for all .toml files
      extensions '.toml'
    end
  end
end
