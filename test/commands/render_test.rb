require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helpers'))

require 'json_pointer'

class InteragentRenderTest < Minitest::Test
  def test_render_for_valid_schema
    markdown = render

    assert_match /An app in our PaaS ecosystem./, markdown
  end

  def test_render_slate_schema
    markdown = render schema: "schemata_slate.md.erb"

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

  def test_render_for_example_as_an_array
    # matches -d '[{...}]' taking into account line breaks and spacing
    expression = /-d '\[[\s\n]+\{[\n\s]+\"name\": \"EXAMPLE\",[\n\s]+\"value\": \"example\"[\s\n]+\}[\n\s]+\]/
    markdown = render
    assert_match expression, markdown
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
        },
        'config-var' => {
          'description' => 'A configuration variable for an app.',
          'title' => 'Config-var',
          'type' => 'object',
          'definitions' => {
            'name' => {
              'description' => 'The config-var\'s name.',
              'type'        => 'string',
              'example'     => 'EXAMPLE'
            },
            'value' => {
              'description' => 'The config-var\'s value.',
              'type'        => 'string',
              'example'     => 'example'
            },
          },
          'links' => [
            {
              'description' => 'Create many config-vars.',
              'href' => '/config-vars',
              'method' => 'PATCH',
              'rel' => 'instances',
              'title' => 'Create Config-var',
              'schema' => {
                'type' => [
                  'array'
                ],
                'items' => {
                  'name' => {
                    '$ref' => '#/definitions/config-var/definitions/name'
                  },
                  'value' => {
                    '$ref' => '#/definitions/config-var/definitions/value'
                  },
                  'example' => [
                    { 'name' => 'EXAMPLE', 'value' => 'example' }
                  ]
                }
              }
            }
          ],
          'properties' => {
            'name' => {
              '$ref' => '#/definitions/config-var/definitions/name'
            },
            'value' => {
              '$ref' => '#/definitions/config-var/definitions/value'
            }
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
        },
        'config-var' => {
          '$ref' => '#/definitions/config-var'
        }
      },
      'type' => 'object'
    }
  end

  def pointer(path)
    JsonPointer.evaluate(data, path)
  end

  def render options = {}
    schema = Prmd::Schema.new(data)

    template = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'prmd', 'templates'))
    Prmd.render(schema, options.merge!(template: template))
  end
end
