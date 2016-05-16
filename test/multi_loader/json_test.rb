require_relative 'common'
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
