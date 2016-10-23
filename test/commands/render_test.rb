require_relative '../helpers'

require 'json_pointer'

class InteragentRenderTest < Minitest::Test
  def test_render_for_valid_schema
    markdown = render

    assert_match(/An app in our PaaS ecosystem./, markdown)
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
    assert_match(/version.*v10\.9\.rc1/, markdown)
  end


  def test_render_for_schema_with_property_defined_with_oneOf
    markdown = render

    assert_match(/\*\*options\/\[OPTION1\]\.type\*\*/, markdown)
    assert_match(/\*\*options\/\[OPTION2\]\.type\*\*/, markdown)
  end

  def test_render_for_toc
    schema = Prmd::Schema.new(data)
    template = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'prmd', 'templates'))
    markdown = Prmd.render(schema, template: template, doc: { toc: true })

    assert_match /^# The table of contents/, markdown
    assert_match '<a href="#resource-app"', markdown
    assert_match '- <a href="#link-POST-app-/apps">POST /apps', markdown
    assert_match '<a name="link-POST-app-/apps"', markdown
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
            'option-type1' => {
              'type' => 'string',
              'example' => 'OPTION1',
              'enum' => 'OPTION1'
            },
            'option-type2' => {
              'type' => 'string',
              'example' => 'OPTION2',
              'enum' => 'OPTION2'
            },
            'option1' => {
              'properties' => {
                'type' => {
                    '$ref' => '#/definitions/config-var/definitions/option-type1'
                }
              }
            },
            'option2' => {
              'properties' => {
                'type' => {
                    '$ref' => '#/definitions/config-var/definitions/option-type2'
                }
              }
            },
            'options' => {
              'items' => {
                'example'=> 'CHOICE1',
                'oneOf' => [
                  {
                    '$ref' => '#/definitions/config-var/definitions/option1'
                  },
                  {
                   '$ref' => '#/definitions/config-var/definitions/option2'
                  }
                ]
              }
            }
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
            },
            'options' => {
              '$ref' => '#/definitions/config-var/definitions/options'
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

  def render
    schema = Prmd::Schema.new(data)

    template = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'prmd', 'templates'))

    Prmd.render(schema, template: template)
  end
end
