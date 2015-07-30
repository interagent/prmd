require File.expand_path(File.join(File.dirname(__FILE__), '.', 'helpers'))
module Prmd
  class LinkTest < MiniTest::Test
    include PrmdLinkTestHelpers

    [
      {
        title: "no_required",
        required: {},
        optional: {"user:email" => "string", "user:name" => "string"}
      },
      {
        title: "parent_required",
        optional: {},
        required: {"user:email" => "string", "user:name" => "string"}
      },
      {
        title: "child_required",
        optional: {"user:name" => "string"},
        required: {"user:email" => "string"}
      }
    ].each do |test_hash|

      define_method "test_#{test_hash[:title]}" do
        subject = Prmd::Link.new( send("link_#{test_hash[:title]}"))
        required, optional = subject.required_and_optional_parameters

        assert_equal required, test_hash[:required]
        assert_equal optional, test_hash[:optional]
      end
    end

  end
end
