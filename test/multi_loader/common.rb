require_relative '../helpers'

module PrmdLoaderTests
  # @abstrac
  def testing_filename
    #
  end

  # @abstract
  def loader_module
    #
  end

  def assert_test_data(data)
    assert_kind_of Hash, data
    assert_equal 'yes', data['test']
    assert_kind_of Hash, data['object']
    assert_equal 'Object', data['object']['is_a']
  end

  def test_load_data
    data = File.read(testing_filename)
    assert_test_data loader_module.load_data(data)
  end

  def test_load_stream
    File.open(testing_filename, 'r') do |f|
      assert_test_data loader_module.load_stream(f)
    end
  end

  def test_load_file
    assert_test_data loader_module.load_file(testing_filename)
  end
end
