require 'prmd/commands/combine'
require 'prmd/rake_tasks/base'

# :nodoc:
module Prmd
  # :nodoc:
  module RakeTasks
    # Schema combine rake task
    #
    # @example
    #   Prmd::RakeTasks::Combine.new do |t|
    #     t.options[:meta] = 'schema/meta.json'
    #     t.paths << 'schema/schemata/api'
    #     t.output_file = 'schema/api.json'
    #   end
    class Combine < Base
      #
      # @return [Array<String>] list of paths
      attr_accessor :paths

      # target file the combined result should be written
      # @return [String>] target filename
      attr_accessor :output_file

      # Creates a new task with name +name+.
      #
      # @overload initialize(name)
      #   @param [String]
      # @overload initialize(options)
      #   @param [Hash<Symbol, Object>] options
      #     .option [String] output_file
      #     .option [Array<String>] paths
      def initialize(*args, &block)
        options = legacy_parameters(*args)
        @paths = options.fetch(:paths) { [] }
        @output_file = options[:output_file]
        super options, &block
      end

      private

      # Default name of the rake task
      #
      # @return [Symbol]
      def default_name
        :combine
      end

      protected

      # Defines the rake task
      # @return [void]
      def define
        desc 'Combine schemas' unless Rake.application.last_description
        task(name) do
          result = Prmd.combine(paths, options)
          if output_file
            File.open(output_file, 'w') do |file|
              file.write(result)
            end
          end
        end
      end
    end
  end
end
