require_relative 'base'
require_relative '../commands/verify'

module Prmd
  module CLI
    # 'verify' command module.
    module Verify
      extend CLI::Base

      # Returns a OptionParser for parsing 'verify' command options.
      #
      # @param (see Prmd::CLI::Base#make_parser)
      # @return (see Prmd::CLI::Base#make_parser)
      def self.make_parser(options = {})
        binname = options.fetch(:bin, 'prmd')

        OptionParser.new do |opts|
          opts.banner = "#{binname} verify [options] <combined schema>"
          opts.on('-y', '--yaml', 'Generate YAML') do |y|
            yield :yaml, y
          end
          opts.on('-o', '--output-file FILENAME', String, 'File to write result to') do |n|
            yield :output_file, n
          end
          opts.on('-s', '--custom-schema FILENAME', String, 'Path to custom schema') do |n|
            yield :custom_schema, n
          end
        end
      end

      # Executes the 'verify' command.
      #
      # @example Usage
      #   Prmd::CLI::Verify.execute(argv: ['schema/api.json'])
      #
      # @param (see Prmd::CLI::Base#execute)
      # @return (see Prmd::CLI::Base#execute)
      def self.execute(options = {})
        filename = options.fetch(:argv).first
        _, data = try_read(filename)
        custom_schema = options[:custom_schema]
        errors = Prmd.verify(data, custom_schema: custom_schema)
        unless errors.empty?
          errors.map! { |error| "#{filename}: #{error}" } if filename
          errors.each { |error| $stderr.puts(error) }
          exit(1)
        end
        result = options[:yaml] ? data.to_yaml : JSON.pretty_generate(data)
        write_result result, options
      end
    end
  end
end
