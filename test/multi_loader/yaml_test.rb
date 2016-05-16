require_relative 'common'
require 'prmd/multi_loader/yaml'

class PrmdMultiLoaderYamlTest < Minitest::Test
  include PrmdLoaderTests

  def loader_module
    Prmd::MultiLoader::Yaml
  end

  def testing_filename
    schemas_path('data/test.yaml')
  end
end
