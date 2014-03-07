require File.join(File.dirname(__FILE__), 'helpers')

class SchemaTest < Minitest::Unit::TestCase
  def test_dereference_with_ref
    ref = user_input_schema.dereference({ "$ref" => "/schema/user#/definitions/id" })
    assert_equal ref, user_input_schema["definitions"]["id"]
  end

  def test_dereference_without_ref
    ref = user_input_schema.dereference("/schema/user#/definitions/id")
    assert_equal ref, user_input_schema["definitions"]["id"]
  end
end
