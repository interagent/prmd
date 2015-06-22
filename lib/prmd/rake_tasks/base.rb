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
      # @return [Hash<Symbol, Object>] the options passed to the Prmd command
      attr_accessor :options

      # Creates a new task with name +name+.
      #
      # @param [Hash<Symbol, Object>] options
      #   .option [String, Symbol] name  the name of the rake task
      #   .option [String, Symbol] options  options to pass to the Prmd command
      def initialize(options = {})
        @name = options.fetch(:name, default_name)
        @options = options.fetch(:options) { {} }

        yield self if block_given?

        define
      end

      private

      # This method will be removed in the future
      # @api private
      def legacy_parameters(*args)
        if args.size == 0
          return {}
        else
          arg, = *args
          case arg
          when String, Symbol
            warn "#{self.class}.new(name) has been deprecated, use .new(name: name) instead"
            return { name: arg }
          else
            return arg
          end
        end
      end

      # Default name of the rake task
      #
      # @return [Symbol]
      def default_name
        :base
      end
    end
  end
end
