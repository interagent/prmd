require 'prmd/core_ext/optparse'
require 'prmd/cli/combine'
require 'prmd/cli/doc'
require 'prmd/cli/generate'
require 'prmd/cli/render'
require 'prmd/cli/verify'

# :nodoc:
module Prmd
  ##
  #
  module CLI
    def self.make_command_parsers(props = {})
      {
        combine: CLI::Combine.make_parser(props),
        doc:     CLI::Doc.make_parser(props),
        init:    CLI::Generate.make_parser(props),
        render:  CLI::Render.make_parser(props),
        verify:  CLI::Verify.make_parser(props)
      }
    end

    def self.make_parser(options, props = {})
      binname = props.fetch(:bin, 'prmd')

      # This is only used to attain the help commands
      commands = make_command_parsers(props)
      help_text = commands.values.map do |command|
        "   #{command.banner}"
      end.join("\n")

      global = OptionParser.new do |opts|
        opts.banner = "Usage: #{binname} [options] [command [options]]"
        opts.separator "\nAvailable options:"
        opts.on('--version', 'Return version') do |opts|
          puts "prmd #{Prmd::VERSION}"
          exit(0)
        end
        opts.on('--noop', 'Commands will not execute') do |v|
          options[:noop] = v
        end
        opts.separator "\nAvailable commands:"
        opts.separator help_text
      end

      global
    end

    def self.parse_options(argv, opts = {})
      options = {}
      parser = make_parser(options, opts)
      abort parser if argv.empty?
      com_argv = parser.order(argv)
      abort parser if com_argv.empty?
      command = com_argv.shift.to_sym
      options[:argv] = com_argv
      options[:command] = command
      options
    end

    def self.run(uargv, opts = {})
      options = parse_options(uargv, opts)
      argv = options.delete(:argv)
      command = options.delete(:command)

      case command
      when :combine
        CLI::Combine.run(argv, options)
      when :doc
        CLI::Doc.run(argv, options)
      when :init
        CLI::Generate.run(argv, options)
      when :render
        CLI::Render.run(argv, options)
      when :verify
        CLI::Verify.run(argv, options)
      end
    end
  end
end
