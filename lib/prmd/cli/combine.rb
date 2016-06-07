require_relative 'base'
require_relative '../commands/combine'

module Prmd
  module CLI
    # 'combine' command module.
    module Combine
      extend CLI::Base

      # Returns a OptionParser for parsing 'combine' command options.
      #
      # @param (see Prmd::CLI::Base#make_parser)
      # @return (see Prmd::CLI::Base#make_parser)
      def self.make_parser(options = {})
        binname = options.fetch(:bin, 'prmd')

        OptionParser.new do |opts|
          opts.banner = "#{binname} combine [options] <file or directory>"
          opts.on('-m', '--meta FILENAME', String, 'Set defaults for schemata') do |m|
            yield :meta, m
          end
          opts.on('-o', '--output-file FILENAME', String, 'File to write result to') do |n|
            yield :output_file, n
          end
          opts.on('-t', '--type-as-string', 'Allow type as string') do |t|
            options[:type_as_string] = t
          end
        end
      end

      # Executes the 'combine' command.
      #
      # @example Usage
      #   Prmd::CLI::Combine.execute(argv: ['schema/schemata/api'],
      #                              meta: 'schema/meta.json',
      #                              output_file: 'schema/api.json',
      #                              type-as-string)
      #
      # @param (see Prmd::CLI::Base#execute)
      # @return (see Prmd::CLI::Base#execute)
      def self.execute(options = {})
        write_result Prmd.combine(options[:argv], options).to_s, options
      end
    end
  end
end
