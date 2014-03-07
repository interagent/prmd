module Prmd
  def self.combine(directory, options={})
    Prmd::Schema.load(directory, options).to_s
  end
end
