require_relative '../helpers'
require 'prmd/cli/generate'

class PrmdCliGenerateTest < Minitest::Test
  include CliBaseTestHelpers

  def command_module
    Prmd::CLI::Generate
  end

  def argv_for_test_run
    ['-y',
     'bread',
     '-o', 'schema/bread.yml']
  end

  def validate_parse_options(options)
    assert_equal true, options[:yaml]
    assert_equal ['bread'], options[:argv]
    assert_equal 'schema/bread.yml', options[:output_file]
    super
  end
end
