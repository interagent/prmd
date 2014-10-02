require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helpers'))

require 'json_pointer'

class InteragentRenderTest < Minitest::Test

  def test_render_for_valid_schema
    markdown = render

    assert_match /An app in our PaaS ecosystem./, markdown
  end

  def test_render_for_schema_with_property_defined_with_anyOf
    pointer('#/definitions/app').merge!({
      'properties' => {
        'version' => {
          'anyOf' => [
            { 'type' => 'string', 'example' => 'v10.9.rc1', 'minLength' => 1 },
            { 'type' => 'number', 'minimum' => 0 }
          ]
        }
      }
    })

    markdown = render
    assert_match /version.*v10\.9\.rc1/, markdown
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
          'definitions' => {
            'identity' => {
              'anyOf' => [
                {
                  '$ref' => '#/definitions/app/definitions/name'
                }
              ]
            },
            'name' => {
              'description' => 'The app\'s name.',
              'type'        => 'string'
            }
          },
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
      'links' => [
        {
          'href' => 'https://example.com',
          'rel' => 'self'
        }
      ],
      'properties' => {
        'app' => {
          '$ref' => '#/definitions/app'
        }
      },
      'type' => 'object'
    }
  end

  def pointer(path)
    JsonPointer.evaluate(data, path)
  end

  def render
    schema = Prmd::Schema.new(data)

    template = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'prmd', 'templates'))

    Prmd.render(schema, template: template)
  end
end
end
