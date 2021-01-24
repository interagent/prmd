module Prmd
  module TimeToJSONSchema
    def to_json(options = {})
      "\"#{xmlschema}\""
    end
  end
end
