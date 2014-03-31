require File.expand_path(File.join(File.dirname(__FILE__), 'helpers'))

class SchemaTest < Minitest::Unit::TestCase
  def test_dereference_with_ref
    key, value = user_input_schema.dereference({
      "$ref" => "/schema/user#/definitions/id"
    })
    assert_equal(key,   "/schema/user#/definitions/id")
    assert_equal(value, user_input_schema["definitions"]["id"])
  end

  def test_dereference_without_ref
    key, value = user_input_schema.dereference("/schema/user#/definitions/id")
    assert_equal(key,   "/schema/user#/definitions/id")
    assert_equal(value, user_input_schema["definitions"]["id"])
  end

  def test_dereference_with_nested_ref
    key, value = user_input_schema.dereference({
      "$ref" => "/schema/user#/definitions/identity"
    })
    assert_equal(key,   "/schema/user#/definitions/id")
    assert_equal(value, user_input_schema["definitions"]["id"])
  end

  def test_dereference_with_local_context
    key, value = user_input_schema.dereference({
      "$ref"     => "/schema/user#/properties/id",
      "override" => true
    })
    assert_equal(key,   "/schema/user#/definitions/id")
    assert_equal(value, {"override" => true}.merge(user_input_schema["definitions"]["id"]))
  end
end
