require_relative "common"
begin
  require "prmd/multi_loader/yajl"
rescue LoadError
end

if defined?(Yajl)
  class PrmdMultiLoaderYajlTest < Minitest::Test
    include PrmdLoaderTests

    def loader_module
      Prmd::MultiLoader::Yajl
    end

    def testing_filename
      schemas_path("data/test.json")
    end
  end
end
