require_relative '../helpers'
require 'prmd/cli/verify'

class PrmdCliVerifyTest < Minitest::Test
  include CliBaseTestHelpers

  def command_module
    Prmd::CLI::Verify
  end

  def argv_for_test_run
    ['-o', 'schema/buttered-bread.json',
     'schema/bread.json']
  end

  def validate_parse_options(options)
    assert_equal 'schema/buttered-bread.json', options[:output_file]
    assert_equal ['schema/bread.json'], options[:argv]
    super
  end
end
