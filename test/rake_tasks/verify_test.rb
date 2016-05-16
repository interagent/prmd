require_relative '../helpers'
require 'prmd/rake_tasks/verify'
require 'rake'

# due to the nature of these Rake Tests, this should not be executed in a
# read-only filesystem or directory.
class PrmdRakeTaskVerifyTest < Minitest::Test
  def test_define_wo_options
    input_file = input_schemas_path('rake_verify.json')
    Prmd::RakeTasks::Verify.new do |t|
      t.name = :verify_wo_options
      t.files = [input_file]
    end
    Rake::Task['verify_wo_options'].invoke
  end

  def test_define_with_options
    input_file = input_schemas_path('rake_verify.json')
    Prmd::RakeTasks::Verify.new(name: :verify_with_options,
                                files: [input_file])
    Rake::Task['verify_with_options'].invoke
  end
end
