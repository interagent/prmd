require 'prmd/commands/render'
require 'prmd/rake_tasks/base'
require 'prmd/load_schema_file'
require 'prmd/url_generator'
require 'prmd/template'
require 'prmd/schema'
require 'prmd/link'

# :nodoc:
module Prmd
  # :nodoc:
  module RakeTasks
    # Documentation rake task
    #
    # @example
    #   Prmd::RakeTasks::Doc.new do |t|
    #     t.files = { 'schema/api.json' => 'schema/api.md' }
    #   end
    class Doc < Base
      # Schema files that should be rendered
      # @return [Array<String>, Hash<String, String>] list of files
      attr_accessor :files

      attr_accessor :toc

      # Creates a new task with name +name+.
      #
      # @overload initialize(name)
      #   @param [String]
      # @overload initialize(options)
      #   @param [Hash<Symbol, Object>] options
      #     .option [Array<String>, Hash<String, String>] files  schema files
      def initialize(*args, &block)
        options = legacy_parameters(*args)
        @files = options.fetch(:files) { [] }
        super options, &block
        @options[:template] ||= Prmd::Template.template_dirname
      end

      private

      # Default name of the rake task
      #
      # @return [Symbol]
      def default_name
        :doc
      end

      # Render file to markdown
      #
      # @param [String] filename
      # @return (see Prmd.render)
      def render_file(filename)
        data = Prmd.load_schema_file(filename)
        schema = Prmd::Schema.new(data)
        Prmd.render(schema, options)
      end

      # Render +infile+ to +outfile+
      #
      # @param [String] infile
      # @param [String] outfile
      # @return [void]
      def render_to_file(infile, outfile)
        result = render_file(infile)
        if outfile
          File.open(outfile, 'w') do |file|
            file.write(result)
          end
        end
      end

      protected

      # Defines the rake task
      # @return [void]
      def define
        desc 'Generate documentation' unless Rake.application.last_description
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
