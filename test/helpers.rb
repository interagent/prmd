require "minitest/autorun"
require "prmd"

def input_schemas_path
  @data_path ||= File.join(File.dirname(__FILE__), 'schemas', 'input')
end

def user_input_schema
  @user_input_schema ||= Prmd::Schema.load(File.join(input_schemas_path, 'user.json'))
end

## Helper to check for any thrown error
def assert_raises_any(exception_kind)
  e = nil
  begin
    yield
  rescue => e
  end
  e.must_be_kind_of exception_kind
end
