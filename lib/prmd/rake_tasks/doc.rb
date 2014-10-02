require 'prmd/commands/render'
require 'prmd/rake_tasks/base'
require 'prmd/load_schema_file'
require 'prmd/template'
require 'prmd/schema'

module Prmd
  module RakeTasks
    class Doc < Base
      # Schema files that should be verified
      # @return [Array<String>, Hash<String, String>] list of files
      attr_accessor :files

      # Creates a new task with name +name+.
      #
      # @param [String, Symbol] name the name of the rake task
      def initialize(name = :doc, &block)
        @files = []
        super name, &block
        @options[:template] ||= Prmd::Template.template_dirname
      end

      private

      def render_file(filename)
        data = Prmd.load_schema_file(filename)
        schema = Prmd::Schema.new(data)
        Prmd.render(schema, options)
      end

      def render_to_file(infile, outfile)
        result = render_file(infile)
        File.open(outfile, 'w') do |file|
          file.write(result)
        end
      end

      protected

      # Defines the rake task
      # @return [void]
      def define
        desc "Verifying schemas" unless ::Rake.application.last_comment
        task(name) do
          if files.is_a?(Hash)
            files.each do |infile, outfile|
              render_to_file(infile, outfile)
            end
          else
            files.each do |infile|
              render_to_file(infile, infile.ext('md'))
            end
          end
        end
      end
    end
  end
end
