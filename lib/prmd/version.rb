module Prmd
  module Version
    MAJOR, MINOR, TEENY, PATCH = 0, 6, 2, nil
    STRING = [MAJOR, MINOR, TEENY, PATCH].compact.join('.').freeze
  end
  VERSION = Version::STRING
end
