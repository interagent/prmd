require 'prmd/commands/combine'
require 'prmd/rake_tasks/base'

module Prmd
  module RakeTasks
    class Combine < Base
      #
      # @return [Array<String>] list of paths
      attr_accessor :paths

      # target file the combined result should be written
      # @return [String>] target filename
      attr_accessor :output_file

      # Creates a new task with name +name+.
      #
      # @param [String, Symbol] name the name of the rake task
      def initialize(name = :combine)
        @paths = []
        super
      end

      protected

      # Defines the rake task
      # @return [void]
      def define
        desc 'Combine schemas' unless Rake.application.last_comment
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
