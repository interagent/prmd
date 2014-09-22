require "prmd/core_ext/optparse"

module Prmd
  module CLI
    def self.parse_options(argv, opts={})
      binname = opts.fetch(:bin, "prmd")
      options = {}

      commands = {
        combine: OptionParser.new do |opts|
          opts.banner = "#{binname} combine [options] <file or directory>"
          opts.on("-m", "--meta FILENAME", String, "Set defaults for schemata") do |m|
            options[:meta] = m
          end
        end,
        doc: OptionParser.new do |opts|
          opts.banner = "#{binname} doc [options] <combined schema>"
          opts.on("-s", "--settings FILENAME", String, "Config file to use") do |s|
            settings = YAML.load_file(s) || {}
            options = HashHelpers.deep_symbolize_keys(settings).merge(options)
          end
          opts.on("-p", "--prepend header,overview", Array, "Prepend files to output") do |p|
            options[:prepend] = p
          end
          opts.on("-c", "--content-type application/json", String, "Content-Type header") do |c|
            options[:content_type] = c
          end
        end,
        init: OptionParser.new do |opts|
          opts.banner = "#{binname} init [options] <resource name>"
          opts.on("-y", "--yaml", "Generate YAML") do |y|
            options[:yaml] = y
          end
        end,
        render: OptionParser.new do |opts|
          opts.banner = "#{binname} render [options] <combined schema>"
          opts.on("-p", "--prepend header,overview", Array, "Prepend files to output") do |p|
            options[:prepend] = p
          end
          opts.on("-t", "--template templates", String, "Use alternate template") do |t|
            options[:template] = t
          end
        end,
        verify: OptionParser.new do |opts|
          opts.banner = "#{binname} verify [options] <combined schema>"
        end
      }

      commands.each_value do |opts|
        opts.on("-o", "--output-file FILENAME", String, "File to write result to") do |n|
          options[:output_file] = n
        end
      end

      help_text = commands.values.map do |command|
        "   #{command.banner}"
      end.join("\n")

      global = OptionParser.new do |opts|
        opts.banner = "Usage: prmd [options] [command [options]]"
        opts.separator "\nAvailable options:"
        opts.on("--version", "Return version") do |opts|
          puts "prmd #{Prmd::VERSION}"
          exit(0)
        end
        opts.separator "\nAvailable commands:"
        opts.separator help_text
      end

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
        File.open(output_file, "w") do |f|
          f.write(data)
        end
      else
        $stdout.puts data
      end
    end

    def self.combine(paths, options={})
      write_result Prmd.combine(paths, options).to_s, options
    end

    def self.doc(filename, options)
      data = unless $stdin.tty?
        $stdin.read
      else
        File.read(filename)
      end
      schema = Prmd::Schema.new(JSON.parse(data))

      options[:template] = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      write_result Prmd.render(schema, options), options
    end

    def self.init(name, options)
      write_result Prmd.init(name, options), options
    end

    def self.render(filename, options)
      data = unless $stdin.tty?
        $stdin.read
      else
        File.read(filename)
      end
      schema = Prmd::Schema.new(JSON.parse(data))
      write_result Prmd.render(schema, options), options
    end

    def self.verify(filename, options)
      data, errors = '', []
      unless $stdin.tty?
        data = $stdin.read
        errors.concat(Prmd.verify(JSON.parse(data)))
      else
        data = JSON.parse(File.read(filename))
        Prmd.verify(data).each do |error|
          errors << "#{filename}: #{error}"
        end
      end
      unless errors.empty?
        errors.each do |error|
          $stderr.puts(error)
        end
        exit(1)
      end
      $stdout.puts data unless $stdout.tty?
    end

    def self.run(uargv, opts={})
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
