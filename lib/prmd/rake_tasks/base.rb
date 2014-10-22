require 'rake'
require 'rake/tasklib'

# :nodoc:
module Prmd
  # :nodoc:
  module RakeTasks
    # Common class for Prmd rake tasks
    #
    # @api private
    class Base < Rake::TaskLib
      # The name of the task
      # @return [String] the task name
      attr_accessor :name

      # Options to pass to command
      # @return [Hash<Symbol, Object>] the options passed to the command
      attr_accessor :options

      # Creates a new task with name +name+.
      #
      # @param [String, Symbol] name the name of the rake task
      def initialize(name)
        @name = name
        @options = {}

        yield self if block_given?

        define
      end
    end
  end
end
