# :nodoc:
module Prmd
  # Well, duh, its a Version module, what did you expect?
  module Version
    MAJOR, MINOR, TEENY, PATCH = 0, 14, 0, nil
    # version string
    # @return [String]
    STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join(".").freeze
  end
  # @return [String]
  VERSION = Version::STRING
end
