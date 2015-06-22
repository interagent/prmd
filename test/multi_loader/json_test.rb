require File.expand_path('common', File.dirname(__FILE__))
require 'prmd/multi_loader/json'

class PrmdMultiLoaderJsonTest < Minitest::Test
  include PrmdLoaderTests

  def loader_module
    Prmd::MultiLoader::Json
  end

  def testing_filename
    schemas_path('data/test.json')
  end
end
