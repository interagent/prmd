require File.expand_path('./helpers', File.dirname(__FILE__))

module Prmd
  class TimeToJSONSchemaTest < Minitest::Test
    def time
      Time.parse('2016-01-01 00:00:00 JST')
    end

    def test_to_json
      Time.prepend TimeToJSONSchema
      assert_equal time.to_json, "\"#{time.xmlschema}\""
    end
  end
end
