require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper')

describe <%= class_name %> do
<% for action in actions -%>
  it "should deliver <%= action.gsub("_", " ") %> message" do
    @expected.subject = '<%= class_name %>#<%= action %>'
    @expected.body    = read_fixture('<%= action %>')
    @expected.date    = Time.now

    @expected.encoded.should == <%= class_name %>.create_<%= action %>(@expected.date).encoded
  end

<% end -%>
end
