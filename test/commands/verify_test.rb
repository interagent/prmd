require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helpers'))

require "json_pointer"

class InteragentHyperSchemaVerifyTest < Minitest::Test
  def test_verifies
    assert_equal [], verify
  end

  #
  # api (root)
  #

  def test_api_required
    data.delete("title")
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#: }, errors[0]
    assert_match %r{Missing required keys "title" in object}, errors[0]
  end

  def test_api_property_format
    pointer("#/properties").merge!({
      "app" => {
        "type" => "string"
      }
    })
    errors = verify
    assert_match %r{^#/properties/app: }, errors[0]
    assert_match %r{Missing required keys "\$ref" in object}, errors[0]
  end

  #
  # resource
  #

  def test_resource_required
    pointer("#/definitions/app").delete("title")
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#/definitions/app: }, errors[0]
    assert_match %r{Missing required keys "title" in object}, errors[0]
  end

  def test_resource_identity_format
    pointer("#/definitions/app/definitions/identity").merge!({
      "type" => "string"
    })
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#/definitions/app/definitions/identity: }, errors[0]
    assert_match %r{any subschema of "anyOf" condition.}, errors[0]
  end

  # an empty schema can be specified to bypass the identity check
  def test_resource_identity_format_empty
    pointer("#/definitions/app/definitions").merge!({
      "identity" => {}
    })
    assert_equal [], verify
  end

  def test_resource_strict_properties
    pointer("#/definitions/app").merge!({
      "strictProperties" => false
    })
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#/definitions/app/strictProperties: }, errors[0]
    assert_match %r{to be a member of enum \[true\], value was: false}, errors[0]
  end

  #
  # resource definition
  #

  def test_resource_definition_no_links
    pointer("#/definitions/app/definitions/name").merge!({
      "links" => []
    })
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#/definitions/app/definitions/name: }, errors[0]
    assert_match %r{Data matched subschema of "not" condition}, errors[0]
  end

  def test_resource_definition_required
    pointer("#/definitions/app/definitions/name").delete("description")
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#/definitions/app/definitions/name: }, errors[0]
    assert_match %r{Missing required keys "description" in object}, errors[0]
  end

  #
  # resource link
  #

  def test_resource_link_href_format
    pointer("#/definitions/app/links/0").merge!({
      "href" => "/my_apps"
    })
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#/definitions/app/links/0/href: }, errors[0]
    assert_match %r{Expected string to match pattern}, errors[0]
  end

  def test_resource_link_required
    pointer("#/definitions/app/links/0").delete("method")
    errors = verify
    assert_equal 1, errors.count
    assert_match %r{^#/definitions/app/links/0: }, errors[0]
    assert_match %r{Missing required keys "method" in object}, errors[0]
  end

  private

  def data
    @data ||= {
      "$schema"     => "http://interagent.github.io/interagent-hyper-schema",
      "description" => "My simple example API.",
      "id"          => "http://example.com/schema",
      "title"       => "Example API",
      "definitions" => {
        "app" => {
          "description" => "An app in our PaaS ecosystem.",
          "title" => "App",
          "type" => "object",
          "definitions" => {
            "identity" => {
              "anyOf" => [
                {
                  "$ref" => "#/definitions/app/definitions/name"
                }
              ]
            },
            "name" => {
              "description" => "The app's name.",
              "type"        => "string"
            }
          },
          "links" => [
            {
              "description" => "Create a new app.",
              "href" => "/apps",
              "method" => "POST",
              "rel" => "create",
              "title" => "Create App"
            }
          ],
          "properties" => {
          }
        }
      },
      "links" => [
        {
          "href" => "https://example.com",
          "rel" => "self"
        }
      ],
      "properties" => {
        "app" => {
          "$ref" => "#/definitions/app"
        }
      },
      "type" => "object"
    }
  end

  def pointer(path)
    JsonPointer.evaluate(data, path)
  end

  def verify
    Prmd.verify(data)
  end
end
