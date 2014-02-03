# Prmd

schema to rule them all

## Introduction

JSON-Schema provides a great way to describe an API. prmd provides tools for bootstrapping a description like this, verifying it's completeness and generating documentation from the specification.

The expectations for json-schema usage that are expected by prmd are described in [/docs/schemata.md](/docs/schemata.md).

To learn more about json-schema in general, start with [this excellent guide](http://spacetelescope.github.io/understanding-json-schema/) and supplement with the [specification](http://json-schema.org/documentation.html).

## Installation

Add this line to your application's Gemfile:

    gem 'prmd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prmd

## Usage

Combine takes the path to a directory of schemas and combines them into a schema.json file in the current directory. If a `_meta.json` file exists, it will also be combined to override defaults/metadata.

```
prmd combine $DIRECTORY
```

Doc takes the path to a directory of schemas and outputs their documentation into a schema.md file in the current directory.

```
prmd doc $DIRECTORY
```

Init takes a path as it's first argument and optionally a resource as it's second argument and generates a new schema file at that path (generically or using the resource name provided). If a `_meta.json` file exists, it will override defaults/metadata in initialized file.

```
prmd init $DIRECTORY
prmd init $DIRECTORY $RESOURCE
```

Verify takes a path to a directory of schemas or a particular schema file and checks to see if it matches expectations.

```
prmd verify $DIRECTORY
prmd verify $SCHEMA
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
