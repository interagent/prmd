require 'prmd/commands/verify'
require 'prmd/rake_tasks/base'
require 'prmd/load_schema_file'

module Prmd
  module RakeTasks
    class Verify < Base
      # Schema files that should be verified
      # @return [Array<String>] list of files
      attr_accessor :files

      # Creates a new task with name +name+.
      #
      # @param [String, Symbol] name the name of the rake task
      def initialize(name = :verify)
        @files = []
        super
      end

      protected

      # Defines the rake task
      # @return [void]
      def define
        desc "Verifying schemas" unless ::Rake.application.last_comment
        task(name) do
          all_errors = []
          files.each do |filename|
            data = Prmd.load_schema_file(filename)
            errors = Prmd.verify(data)
            unless errors.empty?
              errors.map! { |error| "#{filename}: #{error}" } if filename
              errors.each { |error| $stderr.puts(error) }
              all_errors.concat(errors)
            end
          end
          fail unless all_errors.empty?
        end
      end
    end
  end
end
