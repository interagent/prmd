require_relative '../helpers'

class PrmdInitTest < Minitest::Test
  def test_init
    Prmd.init('Cake')
  end
end
