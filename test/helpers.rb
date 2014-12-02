require 'minitest'
require 'minitest/autorun'
require 'prmd'
require 'prmd/cli/base'

module Prmd
  module CLI
    module Base
      # silence noop_execute
      def noop_execute(options = {})
        options
      end
    end
  end
end

module CliBaseTestHelpers
  def argv_for_test_run
    []
  end

  def options_for_test_run
    { }
  end

  def validate_parse_options(options)
    #
  end

  def validate_run_options(options)
    assert_equal options[:noop], true
    validate_parse_options options
  end

  def command_module
    #
  end

  def test_make_parser
    parser = command_module.make_parser
    assert_kind_of OptionParser, parser
  end

  def test_parse_options
    opts = command_module.parse_options(argv_for_test_run, options_for_test_run)

    validate_parse_options opts
  end

  def test_run
    opts = command_module.run(argv_for_test_run,
                              options_for_test_run.merge(noop: true))

    validate_run_options opts
  end
end

module PrmdTestHelpers
  module Paths
    def self.schemas(*args)
      File.join(File.expand_path('schemata', File.dirname(__FILE__)), *args)
    end

    def self.input_schemas(*args)
      schemas('input', *args)
    end

    def self.output_schemas(*args)
      schemas('output', *args)
    end
  end
end

def input_schemas_path(*args)
  PrmdTestHelpers::Paths.input_schemas(*args)
end

def output_schemas_path(*args)
  PrmdTestHelpers::Paths.output_schemas(*args)
end

def user_input_schema
  @user_input_schema ||= Prmd.combine(input_schemas_path('user.json'))
end
