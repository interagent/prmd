require_relative 'helpers'

class UtilsTest < Minitest::Test
  def test_blank?
    assert_equal true, Prmd::Utils.blank?(nil)
    assert_equal true, Prmd::Utils.blank?([])
    assert_equal true, Prmd::Utils.blank?({})
    assert_equal true, Prmd::Utils.blank?("")
    assert_equal true, Prmd::Utils.blank?(" ")
    assert_equal true, Prmd::Utils.blank?("       ")
    assert_equal false, Prmd::Utils.blank?([nil])
    assert_equal false, Prmd::Utils.blank?({ a: nil })
    assert_equal false, Prmd::Utils.blank?("A")
    assert_equal false, Prmd::Utils.blank?(Object.new)
  end
end
