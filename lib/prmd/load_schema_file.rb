require 'yaml'
require 'json'
require_relative 'multi_loader'

module Prmd #:nodoc:
  # Attempts to load either a json or yaml file, the type is determined by
  # filename extension.
  #
  # @param [String] filename
  # @return [Object] data
  def self.load_schema_file(filename)
    Prmd::MultiLoader.load_file(filename)
  end
end
