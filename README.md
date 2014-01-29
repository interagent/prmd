# Prmd

`prmd` helps you manage your JSON schemas. It'll generate schemas from templates, combine schemas, verify schemas, and generate Markdown docs for them.

## Installation

Add this line to your application's Gemfile:

    gem 'prmd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prmd

## Usage

Init takes a path as its first argument and optionally a resource as its second argument and generates a new schema file at that path (generically or using the resource name provided).

```
prmd init $DIRECTORY
prmd init $DIRECTORY $RESOURCE
```

Combine takes the path to a directory of schemas and combines them into a schema.json file in the current directory.

```
prmd combine $DIRECTORY
```

Verify takes a path to a directory of schemas or a particular schema file and checks to see if it matches expectations.

```
prmd verify $DIRECTORY
prmd verify $SCHEMA
```

Doc takes the path to a directory of schemas and outputs their documentation to stdout.

```
prmd doc $DIRECTORY
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
