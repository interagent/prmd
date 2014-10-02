require 'prmd/commands'
require 'prmd/core_ext/optparse'
require 'prmd/hash_helpers'
require 'prmd/load_schema_file'

module Prmd
  module CLI
    def self.make_parsers(options, opts = {})
      binname = opts.fetch(:bin, 'prmd')

      commands = {
        combine: OptionParser.new do |opts|
          opts.banner = "#{binname} combine [options] <file or directory>"
          opts.on('-m', '--meta FILENAME', String, 'Set defaults for schemata') do |m|
            options[:meta] = m
          end
        end,
        doc: OptionParser.new do |opts|
          opts.banner = "#{binname} doc [options] <combined schema>"
          opts.on('-s', '--settings FILENAME', String, 'Config file to use') do |s|
            settings = YAML.load_file(s) || {}
            options = HashHelpers.deep_symbolize_keys(settings).merge(options)
          end
          opts.on('-p', '--prepend header,overview', Array, 'Prepend files to output') do |p|
            options[:prepend] = p
          end
          opts.on('-c', '--content-type application/json', String, 'Content-Type header') do |c|
            options[:content_type] = c
          end
        end,
        init: OptionParser.new do |opts|
          opts.banner = "#{binname} init [options] <resource name>"
          opts.on('-y', '--yaml', 'Generate YAML') do |y|
            options[:yaml] = y
          end
        end,
        render: OptionParser.new do |opts|
          opts.banner = "#{binname} render [options] <combined schema>"
          opts.on('-p', '--prepend header,overview', Array, 'Prepend files to output') do |p|
            options[:prepend] = p
          end
          opts.on('-t', '--template templates', String, 'Use alternate template') do |t|
            options[:template] = t
          end
        end,
        verify: OptionParser.new do |opts|
          opts.banner = "#{binname} verify [options] <combined schema>"
        end
      }

      commands.each_value do |opts|
        opts.on('-o', '--output-file FILENAME', String, 'File to write result to') do |n|
          options[:output_file] = n
        end
      end

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
        opts.separator "\nAvailable commands:"
        opts.separator help_text
      end

      return {
        global: global,
        commands: commands
      }
    end

    def self.parse_options(argv, opts = {})
      options = {}

      parsers = make_parsers(options, opts)
      global = parsers.fetch(:global)
      commands = parsers.fetch(:commands)

      begin
        abort global if argv.empty?

        com_argv = global.order(argv)

        abort global if com_argv.empty?

        command = com_argv.shift.to_sym
        option = commands[command]

        abort global if option.nil?
        abort option if argv.empty? && $stdin.tty?

        rem_argv = option.parse(com_argv)

        options[:argv] = rem_argv
        options[:command] = command
      end

      options
    end

    def self.write_result(data, options)
      if output_file = options[:output_file]
        File.open(output_file, 'w') do |f|
          f.write(data)
        end
      else
        $stdout.puts data
      end
    end

    def self.try_read(filename)
      if filename && !filename.empty?
        return :file, Prmd.load_schema_file(filename)
      elsif !$stdin.tty?
        return :io, JSON.load($stdin.read)
      else
        abort 'Nothing to read'
      end
    end

    def self.combine(paths, options = {})
      write_result Prmd.combine(paths, options).to_s, options
    end

    def self.init(name, options)
      write_result Prmd.init(name, options), options
    end

    def self.render(filename, options)
      _, data = try_read(filename)
      schema = Prmd::Schema.new(data)
      write_result Prmd.render(schema, options), options
    end

    def self.doc(filename, options)
      template = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      render filename, options.merge(template: template)
    end

    def self.verify(filename, options)
      _, data = try_read(filename)
      errors = Prmd.verify(data)
      errors.map! { |error| "#{filename}: #{error}" } if filename
      unless errors.empty?
        errors.each { |error| $stderr.puts(error) }
        exit(1)
      end
      write_result data, options
    end

    def self.run(uargv, opts = {})
      options = parse_options(uargv, opts)
      argv = options.delete(:argv)
      command = options.delete(:command)

      case command
      when :combine
        combine(argv, options)
      when :doc
        doc(argv.first, options)
      when :init
        init(argv.first, options)
      when :render
        render(argv.first, options)
      when :verify
        verify(argv.first, options)
      end
    end
  end
end
