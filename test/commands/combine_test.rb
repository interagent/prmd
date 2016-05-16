require_relative '../helpers'

require 'json_pointer'

class InteragentHyperSchemaCombineTest < Minitest::Test

  #
  # resource link readable href
  #

  def test_resource_link_href_escaping
    pointer('#/definitions/app/links/0').merge!({
      'href' => '/apps/{(#/definitions/app)}'
    })
    assert_equal "/apps/{(%23%2Fdefinitions%2Fapp)}", escaped_href
  end

  def test_resource_link_href_no_double_escaping
    pointer('#/definitions/app/links/0').merge!({
      'href' => '/apps/{(%23%2Fdefinitions%2Fapp)}'
    })
    assert_equal "/apps/{(%23%2Fdefinitions%2Fapp)}", escaped_href
  end

  def test_resource_link_href_no_side_effects
    pointer('#/definitions/app/links/0').merge!({
      'href' => '/apps/foo#bar'
    })
    assert_equal "/apps/foo#bar", escaped_href
  end

  private

  def data
    @data ||= {
      '$schema'     => 'http://interagent.github.io/interagent-hyper-schema',
      'description' => 'My simple example API.',
      'id'          => 'http://example.com/schema',
      'title'       => 'Example API',
      'definitions' => {
        'app' => {
          'description' => 'An app in our PaaS ecosystem.',
          'title' => 'App',
          'type' => 'object',
          'definitions' => {},
          'links' => [
            {
              'description' => 'Create a new app.',
              'href' => '/apps',
              'method' => 'POST',
              'rel' => 'create',
              'title' => 'Create App'
            }
          ],
          'properties' => {
          }
        }
      },
      'links' => [],
      'properties' => {},
      'type' => 'object'
    }
  end

  def pointer(path)
    JsonPointer.evaluate(data, path)
  end

  def escaped_href
    escaped = Prmd::Combine.__send__(:escape_hrefs, data)
    escaped["definitions"]["app"]["links"][0]["href"]
  end
end
