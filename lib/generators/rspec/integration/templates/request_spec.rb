require 'spec_helper'

describe "<%= class_name.pluralize %>" do
  describe "GET /<%= table_name %>" do
    it "works! (now write some real specs)" do
<% if webrat? -%>
      visit <%= table_name %>_path
<% else -%>
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get <%= table_name %>_path
<% end -%>
      response.status.should be(200)
    end
  end
end
