require_relative 'helpers'

class SchemaTest < Minitest::Test
  def test_dereference_with_ref
    key, value = user_input_schema.dereference(
      '$ref' => '#/definitions/user/definitions/id'
    )
    assert_equal(key,   '#/definitions/user/definitions/id')
    user_id = user_input_schema['definitions']['user']['definitions']['id']
    assert_equal(value, user_id)
  end

  def test_dereference_without_ref
    key, value = user_input_schema.dereference(
      '#/definitions/user/definitions/id'
    )
    assert_equal(key,   '#/definitions/user/definitions/id')
    user_id = user_input_schema['definitions']['user']['definitions']['id']
    assert_equal(value, user_id)
  end

  def test_dereference_with_nested_ref
    key, value = user_input_schema.dereference(
      '$ref' => '#/definitions/user/definitions/identity'
    )
    assert_equal(key,   '#/definitions/user/definitions/id')
    user_id = user_input_schema['definitions']['user']['definitions']['id']
    assert_equal(value, user_id)
  end

  def test_dereference_with_local_context
    key, value = user_input_schema.dereference(
      '$ref'     => '#/definitions/user/properties/id',
      'override' => true
    )
    assert_equal(key,   '#/definitions/user/definitions/id')
    user_id = user_input_schema['definitions']['user']['definitions']['id']
    assert_equal(value, { 'override' => true }.merge(user_id))
  end
end
