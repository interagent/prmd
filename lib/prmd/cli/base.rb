require 'json'
require 'fileutils'
require_relative '../core_ext/optparse'
require_relative '../load_schema_file'

module Prmd
  module CLI
    # Base module for CLI commands.
    # @api
    module Base
      SCHEMA_INDEX_FILENAME = 'schema.md'

      # Create a parser specific for this command.
      # The parsers produced by this method should yield their options.
      #
      # @example Overwriting
      #   def make_parser(options = {})
      #     OptionParser.new do |opts|
      #       opts.on("-v", "--verbose", "set verbose debugging") do |v|
      #         yield :verbose, v
      #       end
      #     end
      #   end
      #
      # @param [Hash<Symbol, Object>] options
      # @return [OptionParser] newly created parser
      # @abstract
      def make_parser(options = {})
        #
      end

      # Runs the provided parser with the provided argv.
      # This method can be overwritten to use a different parser method.
      #
      # @param [OptionParser] parser
      # @param [Array<String>] argv
      # @return [Array<String>] remaining arguments
      # @private
      def execute_parser(argv)
        @parser.parse(argv)
      end

      # Set the given key and value in the given options Hash.
      # This method can ben overwritten to support special keys or values
      #
      # @example Handling special keys
      #   def self.set_option(options, key, value)
      #     if key == :settings
      #       options.replace(value.merge(options))
      #     else
      #       super
      #     end
      #   end
      #
      # @param [Hash<Symbol, Object>] options
      # @param [Symbol] key
      # @param [Object] value
      # @return [void]
      def set_option(options, key, value)
        options[key] = value
      end

      # Parse the given argv and produce a options Hash specific to the command.
      # The returned options Hash will include an :argv key which contains
      # the remaining args from the parse operation.
      #
      # @param [Array<String>] argv
      # @param [Hash<Symbol, Object>] options
      # @return [Hash<Symbol, Object>] parsed options
      def parse_options(argv, options = {})
        opts = {}
        @parser = make_parser(options) do |key, value|
          set_option(opts, key, value)
        end
        argv = execute_parser(argv)
        opts[:argv] = argv
        opts
      end

      # Helper method for writing command results to a file or STD* IO.
      #
      # @param [String] data  to be written
      # @param [Hash<Symbol, Object>] options
      # @return [void]
      def write_result(data, options = {})

        output_file = options[:output_file]
        output_dir = options[:output_dir]
        if output_file
          File.open(output_file, 'w') do |f|
            f.write(data)
          end
        elsif output_dir
          schema_index = data.delete(SCHEMA_INDEX_FILENAME)
          File.open(File.join(output_dir, SCHEMA_INDEX_FILENAME), 'w') do |f|
            f.write(schema_index)
          end

          subdir = File.join(output_dir, 'mds')
          FileUtils.mkdir(File.join(output_dir, 'mds')) unless File.exists?(subdir)

          data.each do |filename, d|
            File.open(File.join(subdir, filename), 'w') do |f|
              f.write(d)
            end
          end
        else
          $stdout.puts data
        end
      end

      # Helper method for reading schema data from a file or STD* IO.
      #
      # @param [String] filename  file to read
      # @return [Array[Symbol, String]] source, data
      def try_read(filename = nil)
        if filename && !filename.empty?
          return :file, Prmd.load_schema_file(filename)
        elsif !$stdin.tty?
          return :io, JSON.load($stdin.read)
        else
          abort 'Nothing to read'
        end
      end

      # Method called to actually execute the command provided with an
      # options Hash from the commands #parse_options.
      #
      # @param [Hash<Symbol, Object>] options
      # @return [void]
      # @abstract
      def execute(options = {})
        #
      end

      # Method called when the command is ran with the :noop option enabled.
      # As the option implies, this should do absolutely nothing.
      #
      # @param [Hash<Symbol, Object>] options
      # @return [void]
      def noop_execute(options = {})
        $stderr.puts options
      end

      # Run this command given a argv and optional options Hash.
      # If all you have is the options from the #parse_options method, use
      # #execute instead.
      #
      # @see #execute
      # @see #parse_options
      #
      # @param [Array<String>] argv
      # @param [Hash<Symbol, Object>] options
      # @return [void]
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
