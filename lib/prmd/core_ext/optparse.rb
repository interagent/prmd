require "optparse"

# Extension of the standard library OptionParser
class OptionParser
  alias_method :to_str, :to_s
end
