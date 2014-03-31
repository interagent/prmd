require File.join(File.dirname(__FILE__), 'helpers')

class SchemaTest < Minitest::Unit::TestCase
  def test_recursive_dereference_with_ref
    ref, key = user_input_schema.dereference({ '$ref' => '/schema/user#/definitions/identity' })
    assert_equal ref, user_input_schema['definitions']['id']
    assert_equal key, 'id'
  end

  def test_recursive_dereference_without_ref
    ref, key = user_input_schema.dereference('/schema/user#/definitions/identity')
    assert_equal ref, user_input_schema['definitions']['id']
    assert_equal key, 'id'
  end


  def test_unnecessary_dereference
    subschema = user_input_schema['definitions']['created_at']
    ref, key = user_input_schema.dereference(subschema)
    assert_equal ref, subschema
    assert_nil key

    ref, key = user_input_schema.dereference(subschema, 'created_at')
    assert_equal ref, subschema
    assert_equal key, 'created_at'
  end

  def test_invalid_dereference
    assert_raises_any(Exception) { capture_io { user_input_schema.dereference('/schema/user#/definitions/unknown') } }
  end
end
