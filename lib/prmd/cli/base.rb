require 'json'
require 'prmd/core_ext/optparse'
require 'prmd/load_schema_file'

# :nodoc:
module Prmd
  # :nodoc:
  module CLI
    # @api private
    module Base
      def make_parser(options = {})
        #
      end

      def execute_parser(parser, argv)
        parser.parse!(argv)
      end

      def set_option(options, key, value)
        options[key] = value
      end

      def parse_options(argv, opts = {})
        options = {}
        parser = make_parser(opts) do |key, value|
          set_option(options, key, value)
        end
        argv = execute_parser(parser, argv)
        options[:argv] = argv
        options
      end

      def write_result(data, options = {})
        output_file = options[:output_file]
        if output_file
          File.open(output_file, 'w') do |f|
            f.write(data)
          end
        else
          $stdout.puts data
        end
      end

      def try_read(filename = nil)
        if filename && !filename.empty?
          return :file, Prmd.load_schema_file(filename)
        elsif !$stdin.tty?
          return :io, JSON.load($stdin.read)
        else
          abort 'Nothing to read'
        end
      end

      def execute(options = {})
        #
      end

      def noop_execute(options = {})
        $stderr.puts options
      end

      def run(argv, options = {})
        options = options.merge(parse_options(argv, options))
        if options[:noop]
          noop_execute(options)
        else
          execute(options)
        end
      end

      private :execute_parser
      private :set_option
      private :write_result
      private :try_read
    end
  end
end
