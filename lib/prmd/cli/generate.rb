require 'prmd/cli/base'
require 'prmd/commands/init'

module Prmd
  module CLI
    # 'init' command module.
    # Though this is called, Generate, it is used by the init method for
    # creating new Schema files
    module Generate
      extend CLI::Base

      # Returns a OptionParser for parsing 'init' command options.
      #
      # @param (see Prmd::CLI::Base#make_parser)
      # @return (see Prmd::CLI::Base#make_parser)
      def self.make_parser(options = {})
        binname = options.fetch(:bin, 'prmd')

        OptionParser.new do |opts|
          opts.banner = "#{binname} init [options] <resource name>"
          opts.on('-y', '--yaml', 'Generate YAML') do |y|
            yield :yaml, y
          end
          opts.on('-o', '--output-file FILENAME', String, 'File to write result to') do |n|
            yield :output_file, n
          end
        end
      end

      # Executes the 'init' command.
      #
      # @example Usage
      #   Prmd::CLI::Generate.execute(argv: ['bread'],
      #                               output_file: 'schema/schemata/bread.json')
      #
      # @param (see Prmd::CLI::Base#execute)
      # @return (see Prmd::CLI::Base#execute)
      def self.execute(options = {})
        name = options.fetch(:argv).first
        write_result Prmd.init(name, options), options
      end
    end
  end
end
