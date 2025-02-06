require_relative "common"
begin
  require "prmd/multi_loader/toml"
rescue LoadError
end

if defined?(TOML)
  class PrmdMultiLoaderTomlTest < Minitest::Test
    include PrmdLoaderTests

    def loader_module
      Prmd::MultiLoader::Toml
    end

    def testing_filename
      schemas_path("data/test.toml")
    end
  end
end
