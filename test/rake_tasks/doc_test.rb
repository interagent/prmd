require_relative '../helpers'
require 'prmd/rake_tasks/doc'
require 'rake'

# due to the nature of these Rake Tests, this should not be executed in a
# read-only filesystem or directory.
class PrmdRakeTaskDocTest < Minitest::Test
  def test_define_wo_options
    input_file = input_schemas_path('rake_doc.json')
    #output_file = output_schemas_path('rake_doc_with_options.md')
    output_file = nil
    File.delete(output_file) if File.exist?(output_file) if output_file
    Prmd::RakeTasks::Doc.new do |t|
      t.name = :doc_wo_options
      t.files = { input_file => output_file }
    end
    Rake::Task['doc_wo_options'].invoke
    assert File.exist?(output_file) if output_file
  end

  def test_define_with_options
    input_file = input_schemas_path('rake_doc.json')
    #output_file = output_schemas_path('rake_doc_with_options.md')
    output_file = nil
    File.delete(output_file) if File.exist?(output_file) if output_file
    Prmd::RakeTasks::Doc.new(name: :doc_with_options,
                             files: { input_file => output_file })
    Rake::Task['doc_with_options'].invoke
    assert File.exist?(output_file) if output_file
  end
end
