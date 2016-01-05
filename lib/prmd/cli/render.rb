require_relative 'base'
require_relative '../commands/render'

module Prmd
  module CLI
    # 'render' command module.
    module Render
      extend CLI::Base

      # Returns a OptionParser for parsing 'render' command options.
      #
      # @param (see Prmd::CLI::Base#make_parser)
      # @return (see Prmd::CLI::Base#make_parser)
      def self.make_parser(options = {})
        binname = options.fetch(:bin, 'prmd')

        OptionParser.new do |opts|
          opts.banner = "#{binname} render [options] <combined schema>"
          opts.on('-c', '--content-type application/json', String, 'Content-Type header') do |c|
            yield :content_type, c
          end
          opts.on('-o', '--output-file FILENAME', String, 'File to write result to') do |n|
            yield :output_file, n
          end
          opts.on('-p', '--prepend header,overview', Array, 'Prepend files to output') do |p|
            yield :prepend, p
          end
          opts.on('-t', '--template templates', String, 'Use alternate template') do |t|
            yield :template, t
          end
        end
      end

      # Executes the 'render' command.
      #
      # @example Usage
      #   Prmd::CLI::Render.execute(argv: ['schema/api.json'],
      #                             template: 'my_template.md.erb',
      #                             output_file: 'schema/api.md')
      #
      # @param (see Prmd::CLI::Base#execute)
      # @return (see Prmd::CLI::Base#execute)
      def self.execute(options = {})
        filename = options.fetch(:argv).first
        _, data = try_read(filename)
        schema = Prmd::Schema.new(data)
        write_result Prmd.render(schema, options), options
      end
    end
  end
end
