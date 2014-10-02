require 'minitest'
require 'minitest/autorun'
require 'prmd'

def input_schemas_path(*args)
  @data_path ||= File.expand_path(File.join(*args),
                                  File.join(File.dirname(__FILE__),
                                            'schemata/input'))
end

def user_input_schema
  @user_input_schema ||= Prmd.combine(input_schemas_path('user.json'))
end
