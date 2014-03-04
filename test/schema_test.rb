require "minitest/autorun"
require "prmd"

class SchemaTest < Minitest::Unit::TestCase
  def setup
    @schema = Prmd::Schema.new({
      "$schema" => "http://json-schema.org/draft-04/schema",
      "definitions" => {
        "address" => {
          "type" => "object",
          "properties" => {
            "street_address" => { "type" => "string" },
            "city" => { "type" => "string" },
            "state" => { "type" => "string" }
          },
          "required" => ["street_address", "city", "state"]
        }
      },
      "type" => "object",
      "properties" => {
        "billing_address" => { "$ref" => "#/definitions/address" },
        "shipping_address" => { "$ref" => "#/definitions/address" }
      }
    })
  end

  def test_dereference_with_ref
    ref = @schema.dereference(@schema.data["properties"]["billing_address"])
    assert_equal ref, @schema.data["definitions"]["address"]
  end

  def test_dereference_without_ref
    ref = @schema.dereference(@schema.data["definitions"]["address"])
    assert_equal ref, @schema.data["definitions"]["address"]
  end
end
