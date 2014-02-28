module Prmd
  def self.combine(directory)
    new_schema = Prmd::Schema.load(directory).to_s
    old_schema = File.read('schema.json')
    Diff::LCS.diff(old_schema.split("\n"), new_schema.split("\n")).each do |diff|
      $stderr.puts("#{diff.first.position}..#{diff.last.position}")
      diff.each do |change|
        $stderr.puts("#{change.action} #{change.element}")
      end
    end
    puts new_schema
  end
end
