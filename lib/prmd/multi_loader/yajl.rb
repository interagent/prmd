require_relative 'loader'
require 'yajl'

module Prmd #:nodoc:
  module MultiLoader #:nodoc:
    # JSON MultiLoader using Yajl
    module Yajl
      extend Prmd::MultiLoader::Loader

      # @see (Prmd::MultiLoader::Loader#load_data)
      def self.load_data(data)
        ::Yajl::Parser.parse(data)
      end

      # register this loader for all .json files
      extensions '.json'
    end
  end
end
