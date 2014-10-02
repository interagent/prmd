require 'prmd/cli/base'
require 'prmd/commands/render'

module Prmd
  module CLI
    module Render
      extend CLI::Base

      def self.make_parser(options = {})
        binname = options.fetch(:bin, 'prmd')

        OptionParser.new do |opts|
          opts.banner = "#{binname} render [options] <combined schema>"
          opts.on('-p', '--prepend header,overview', Array, 'Prepend files to output') do |p|
            yield :prepend, p
          end
          opts.on('-t', '--template templates', String, 'Use alternate template') do |t|
            yield :template, t
          end
          opts.on('-o', '--output-file FILENAME', String, 'File to write result to') do |n|
            yield :output_file, n
          end
        end
      end

      def self.execute(options = {})
        filename = options.fetch(:argv).first
        _, data = try_read(filename)
        schema = Prmd::Schema.new(data)
        write_result Prmd.render(schema, options), options
      end
    end
  end
end
