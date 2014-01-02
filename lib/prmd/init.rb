module Prmd
  def self.init(path)
    schema = {
      '$schema'     => 'http://json-schema.org/draft-04/hyper-schema',
      'definitions' => {},
      'links'       => [],
      'properties'  => {},
      'type'        => ['object']
    }
    File.open(path, 'w') do |file|
      file.write(JSON.pretty_generate(schema))
    end
  end
end
