require "minitest/autorun"
require "prmd"

def input_schemas_path
  @@data_path ||= File.join(File.dirname(__FILE__), 'schemas', 'input')
end

def user_input_schema
  @@user_input_schema ||= Prmd.combine(File.join(input_schemas_path, 'user.json'))
end
