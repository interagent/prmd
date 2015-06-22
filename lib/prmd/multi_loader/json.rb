require_relative 'loader'
require 'json'

module Prmd #:nodoc:
  module MultiLoader #:nodoc:
    # JSON MultiLoader
    module Json
      extend Prmd::MultiLoader::Loader

      # @see (Prmd::MultiLoader::Loader#load_data)
      def self.load_data(data)
        ::JSON.load(data)
      end

      # register this loader for all .json files
      extensions '.json'
    end
  end
end
