module Prmd
  module CLI
    def self.run(argv)
      options = {}

      commands = {
        combine: OptionParser.new do |opts|
          opts.banner = "prmd combine [options] <file or directory>"
          opts.on("-m", "--meta meta.json", "Set defaults for schemata") do |m|
            options[:meta] = m
          end
        end,
        doc: OptionParser.new do |opts|
          opts.banner = "prmd doc [options] <combined schema>"
          opts.on("-s", "--settings prmd-config.json", String, "Config file to use") do |s|
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
          opts.banner = "prmd init [options] <resource name>"
          opts.on("-y", "--yaml", "Generate YAML") do |y|
            options[:yaml] = y
          end
        end,
        render: OptionParser.new do |opts|
          opts.banner = "prmd render [options] <combined schema>"
          opts.on("-p", "--prepend header,overview", Array, "Prepend files to output") do |p|
            options[:prepend] = p
          end
          opts.on("-t", "--template templates", String, "Use alternate template") do |t|
            options[:template] = t
          end
        end,
        verify: OptionParser.new do |opts|
          opts.banner = "prmd verify [options] <combined schema>"
        end
      }

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

      if argv.empty?
        puts global
        exit(1)
      end
      global.order!

      command = argv.shift.to_sym
      option = commands[command]
      if option.nil?
        puts global
        exit(1)
      end

      if argv.empty? && $stdin.tty?
        puts option
        exit(1)
      end
      option.order!

      case command
        when :combine
          puts Prmd.combine(argv, options).to_s
        when :doc
          data = unless $stdin.tty?
            $stdin.read
          else
            File.read(argv[0])
          end
          schema = Prmd::Schema.new(JSON.parse(data))

          options[:template] = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

          puts Prmd.render(schema, options)
        when :init
          puts Prmd.init(argv[0], options)
        when :render
          data = unless $stdin.tty?
            $stdin.read
          else
            File.read(argv[0])
          end
          schema = Prmd::Schema.new(JSON.parse(data))
          puts Prmd.render(schema, options)
        when :verify
          data, errors = '', []
          unless $stdin.tty?
            data = $stdin.read
            errors.concat(Prmd.verify(JSON.parse(data)))
          else
            data = JSON.parse(File.read(argv[0]))
            Prmd.verify(data).each do |error|
              errors << "#{argv[0]}: #{error}"
            end
          end
          errors.each do |error|
            $stderr.puts(error)
          end
          exit(1) unless errors.empty?
          puts(data) unless $stdout.tty?
      end
    end
  end
end
