# schemata
This document seeks to explain JSON schema in practice as well as our usage and associated implications. Everything described must be followed unless otherwise noted (or it is a bug). Unless otherwise noted (as in meta-data) keys should be alphabetized for ease of modification/review/updating. A great example in-the-wild is available for the Heroku Platform API, see [Heroku Devcenter](https://devcenter.heroku.com/articles/platform-api-reference#schema) for details.

## json-schema

JSON Schema provides a way to describe the resources, attributes and links of an API using JSON. This document will contain many examples and explanation, but going to the source can also be useful. There are three relevant specs, which are additive. You can read through them, ideally in this order:

1. [JSON Schema Core](http://tools.ietf.org/html/draft-zyp-json-schema-04) - defines the basic foundation of JSON Schema - you probably will not need this often
2. [JSON Schema Validation](http://tools.ietf.org/html/draft-fge-json-schema-validation-00) - defines the validation keywords of JSON Schema - covers most attributes
3. [JSON Hyper-Schema](http://tools.ietf.org/html/draft-luff-json-hyper-schema-00) - defines the hyper-media keywords of JSON Schema - covers remaining links-specific attributes

## structure

We have opted to split apart the schema into individual resource schema and a root schema which references all of them. These individual schema are named based on the singular form of the resource in question.

### meta-data

Each schema MUST include some meta-data, which we cluster at the top of the file, including:

* `description` - a description of the resource described by the schema
* `id` - an id for this schema, it MUST be in the form `"schemata/#{lower_case_singular_resource}"`
* `$schema` - defines what meta-schema is in use, it MUST be `http://json-schema.org/draft-04/hyper-schema`
* `title` - title for this resource, it MUST be in the form `"#{title_case_API_name} - #{title_case_plural_resource}"`
* `type` - the type(s) of this schema, it MUST be `["object"]`

### `definitions`

We make heavy usage of the `definitions` attribute in each resource to provide a centralized collection of attributes related to each resource. By doing so we are able to refer to the same attribute in links, properties and even as foreign keys.

The definitions object MUST include every attribute related directly to this resource, including:

* all properties that are present in the serialization of the object
* an `identity` property to provide an easy way to find what unique identifier(s) can be used with this object as well as what to use for foreign keys
* all transient properties which may be passed into links related to the object, even if they are not serialized

Each attribute MUST include the following properties:

* `description` - a description of the attribute and how it relates to the resource
* `example` - an example of the attributes value, useful for documentation and tests
* `type` - an array of type(s) for this attribute, values MUST be one of `["array", "boolean", "integer", "number", "null", "object", "string"]`

Each attribute MAY include the following properties:

* `pattern` - a javascript regex encoded in a string that the valid values MUST match
* `format` - format of the value. MUST be one of spec defined `["date", "date-time", "email", "hostname", "ipv4", "ipv6", "uri"]` or defined by us `["uuid"]`

Examples:

```javascript
{
  "definitions": {
    "id": {
      "description":  "unique identifier of resource",
      "example":      "01234567-89ab-cdef-0123-456789abcdef",
      "format":       "uuid",
      "type":         ["string"]
    },
    "url": {
      "description":  "URL of resource",
      "example":      "http://example.com",
      "format":       "uri",
      "pattern":      "^http://[a-z][a-z0-9-]{3,30}\\.com$",
      "type":         ["null", "string"]
    }
  }
}
```

### `links`

Links define the actions available on a given resource. They are listed as an array, which should be alphabetized by title.

The links array MUST include an object defining each action available. Each action MUST include the following attributes:

* `description` - a description of the action to perform
* `href` - the path associated with this action, use [URI templates](http://tools.ietf.org/html/rfc6570) as needed, CGI escaping any JSON pointer values used for identity
* `method` - the http method to be used with this action
* `rel` - describes relation of link to resource, SHOULD be one of `["create", "destroy", "self", "instances", "update"]`
* `title` - title for the link

Links that expect a json-encoded body as input MUST also include the following attributes:
* `schema` - an object with a `properties` object that MUST include JSON pointers to the definitions for each associated attribute

The `schema` object MAY also include a `required` array to define all attributes for this link, which can not be omitted.
If this field is not present, all attributes in this link are considered as optional.

Links that expect a custom http header MUST include the following attributes:
* `http_header` - an object which has the key as the header name, and value as an example header value.

```javascript
{
  "links": [
    {
      "description":  "Create a new resource.",
      "href":         "/resources",
      "method":       "POST",
      "rel":          "create",
      "http_header": { "Custom-Header": "examplevalue" },
      "schema":       {
        "properties": {
          "owner":  { "$ref": "/schemata/user#/definitions/identity" },
          "url":    { "$ref": "/schemata/resource/definitions/url" }
        },
        "required": [ "owner", "url" ]
      },
      "title":        "Create"
    },
    {
      "description":  "Delete an existing resource.",
      "href":         "/resources/{(%2Fschemata%2Fresources%23%2Fdefinitions%2Fidentity)}",
      "method":       "DELETE",
      "rel":          "destroy",
      "title":        "Delete"
    },
    {
      "description":  "Info for existing resource.",
      "href":         "/resources/{(%2Fschemata%2Fresources%23%2Fdefinitions%2Fidentity)}",
      "method":       "GET",
      "rel":          "self",
      "title":        "Info"
    },
    {
      "description":  "List existing resources.",
      "href":         "/resources",
      "method":       "GET",
      "rel":          "instances",
      "title":        "List"
    },
    {
      "description":  "Update an existing resource.",
      "href":         "/resources/{(%2Fschemata%2Fresource%23%2Fdefinitions%2Fidentity)}",
      "method":       "PATCH",
      "rel":          "update",
      "schema":       {
        "properties": {
          "url":    { "$ref": "/schemata/resource/definitions/url" }
        }
      },
      "title":        "Update"
    }
  ]
}
```

Links MAY specify a different serialization than defined in [properties](#properties) via `targetSchema`.

### `properties`

Properties defines the attributes that exist in the serialization of the object.

The properties object MUST contain all the serialized attributes for the object. Each attribute MUST provide a [JSON pointer](http://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-07) to the attribute in appropriate `definitions`, we have opted to always use absolute pointers for consistency. Properties MUST also add any data which overrides the values in definitions and SHOULD add any additional, relevant data.

```javascript
{
  "properties": {
    "id":       { "$ref": "/schemata/resource#/definitions/id" },
    "owner": {
      "description": "unique identifier of the user who owns this resource",
      "properties": {
        "id": { "$ref": "/schemata/user#/definitions/id" }
      },
      "type": ["object"]
    },
    "url":      { "$ref": "/schemata/resource#/definitions/url" }
  }
}
```

Note: this assumes that schema/user will also be available and will have id defined in the definitions. If/when you need to refer to a foreign key, you MUST add a new schema and/or add the appropriate attribute to the foreign resource definitions unless it already exists.
