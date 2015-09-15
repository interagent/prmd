require_relative 'base'

module Prmd
  module CLI
    # 'stub' command module'
    module Stub
      extend CLI::Base

      # Returns a OptionParser for parsing 'stub' command options.
      #
      # @param (see Prmd::CLI::Base#make_parser)
      # @return (see Prmd::CLI::Base#make_parser)
      def self.make_parser(options = {})
        binname = options.fetch(:bin, 'prmd')

        OptionParser.new do |opts|
          opts.banner = "#{binname} stub [options] <combined schema>"
        end
      end

      # Executes the 'stub' command.
      #
      # @example Usage
      #   Prmd::CLI::Stub.execute(argv: ['schema/api.json'])
      #
      # @param (see Prmd::CLI::Base#execute)
      # @return (see Prmd::CLI::Base#execute)
      def self.execute(options = {})
        require "committee"

        filename = options.fetch(:argv).first
        _, schema = try_read(filename)

        app = Rack::Builder.new {
          use Committee::Middleware::RequestValidation, schema: schema
          use Committee::Middleware::ResponseValidation, schema: schema
          use Committee::Middleware::Stub, schema: schema
          run lambda { |_| [404, {}, ["Not found"]] }
        }

        Rack::Server.start(app: app)
      end
    end
  end
end
