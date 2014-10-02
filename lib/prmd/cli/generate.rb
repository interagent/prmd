require 'prmd/cli/base'
require 'prmd/commands/init'

module Prmd
  module CLI
    module Generate
      extend CLI::Base

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

      def self.execute(options = {})
        name = options.fetch(:argv).first
        write_result Prmd.init(name, options), options
      end
    end
  end
end
