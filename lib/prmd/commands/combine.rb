module Prmd
  def self.combine(directory)
    return Prmd::Schema.load(directory)
  end
end
