require 'prmd/cli/base'
require 'prmd/commands/combine'

module Prmd
  module CLI
    module Combine
      extend CLI::Base

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
        end
      end

      def self.execute(options = {})
        write_result Prmd.combine(options[:argv], options).to_s, options
      end
    end
  end
end
