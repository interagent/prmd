require 'prmd/cli/base'
require 'prmd/commands/verify'

module Prmd
  module CLI
    module Verify
      extend CLI::Base

      def self.make_parser(options = {})
        binname = options.fetch(:bin, 'prmd')

        OptionParser.new do |opts|
          opts.banner = "#{binname} verify [options] <combined schema>"

          opts.on('-o', '--output-file FILENAME', String, 'File to write result to') do |n|
            yield :output_file, n
          end
        end
      end

      def self.execute(options = {})
        filename = options.fetch(:argv).first
        _, data = try_read(filename)
        errors = Prmd.verify(data)
        unless errors.empty?
          errors.map! { |error| "#{filename}: #{error}" } if filename
          errors.each { |error| $stderr.puts(error) }
          exit(1)
        end
        write_result data, options
      end
    end
  end
end
