# Prmd

JSON Schema tooling: scaffold, verify, and generate documentation
against JSON Schema documents.


## Introduction

[JSON-Schema](http://json-schema.org/) provides a great way to describe
an API. prmd provides tools for bootstrapping a description like this,
verifying its completeness, and generating documentation from the
specification.

The expectations for JSON Schema usage that are expected by prmd are
described in [/docs/schemata.md](/docs/schemata.md).

To learn more about json-schema in general, start with [this excellent guide](http://spacetelescope.github.io/understanding-json-schema/) and supplement with the [specification](http://json-schema.org/documentation.html).

## Installation

Add this line to your application's Gemfile:

    gem 'prmd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prmd

## Usage

Combine takes the path to a directory of schemas and combines them onto stdout. If -m or --meta is supplied, it will override defaults/metadata.

```
prmd combine <directory>
```

Doc takes the path to a directory of schemas and outputs their documentation onto stdout. If -m or --meta is supplied, it will override defaults/metadata.

```
prmd doc <directory_or_schema>
```

Prepend file to the documentation output.

```
prmd doc -p header.md,overview.md <directory or schema>
```

Init optionally takes a resource as it's first argument and generates a new schema file to stdout (generically or using the resource name provided). If -m or --meta is supplied, it will override defaults/metadata.

```
prmd init
prmd init <resource_name>
```

Verify takes a path to a directory of schemas or a particular schema file and checks to see if it matches expectations.

```
prmd verify <directory_or_schema>
```

Combining commands works too.

```
prmd combine <directory> | prmd verify | prmd doc > schema.md
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
