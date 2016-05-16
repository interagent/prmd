require_relative '../helpers'

module Prmd
  class ReferenceLocalizerTest < Minitest::Test
    def base_object
      {
        "type" => ["object"],
        "properties" => {
          "name" => {
            "type" => ["nil", "string"],
            "example" => "john",
          },
          "age" => {
            "type" => ["nil", "number"],
            "example" => 37,
          },
        },
      }
    end

    def test_no_references
      object = base_object
      assert_equal object, ReferenceLocalizer.localize(object)
    end

    def test_simple_ref
      object = base_object.merge(
        "properties" => base_object["properties"].merge(
          "name" => { "$ref" => "#/attributes/definitions/name" },
        ),
      )

      new_object = ReferenceLocalizer.localize(object)
      assert_equal "#/definitions/attributes/definitions/name",
                   new_object["properties"]["name"]["$ref"]
    end

    def test_simple_href
      object = base_object.merge("href" => "%23%2Fschemata%2Fhello%2Fworld")
      new_object = ReferenceLocalizer.localize(object)
      assert_equal "%23%2Fdefinitions%2Fhello%2Fworld", new_object["href"]

      object = base_object.merge("href" => "%23%2Fhello%2Fworld")
      new_object = ReferenceLocalizer.localize(object)
      assert_equal "%2Fhello%2Fworld", new_object["href"]
    end

    def test_aliases
      object = base_object.merge(
        "properties" => base_object["properties"].merge(
          "name" => { "$ref" => "#/attributes/definitions/name" },
        ),
      )
      object["properties"]["translated_name"] = object["properties"]["name"]

      new_object = ReferenceLocalizer.localize(object)

      assert_equal "#/definitions/attributes/definitions/name",
                   new_object["properties"]["name"]["$ref"]

      assert_equal "#/definitions/attributes/definitions/name",
                   new_object["properties"]["translated_name"]["$ref"]
    end
  end
end
