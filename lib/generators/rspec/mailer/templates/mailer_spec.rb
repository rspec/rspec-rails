require 'spec_helper'

describe <%= class_name %> do
<% for action in actions -%>
  it "should deliver <%= action.gsub("_", " ") %> message" do
    @expected.subject = <%= action.to_s.humanize.inspect %>
    @expected.to      = "to@example.org"
    @expected.from    = "from@example.com"
    @expected.body    = read_fixture("<%= action %>")
  end

<% end -%>
end
