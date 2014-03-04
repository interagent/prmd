module Prmd
  def self.combine(directory)
    Prmd::Schema.load(directory).to_s
  end
end
