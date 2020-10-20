require 'rails_helper'

RSpec.describe "<%= class_name.pluralize %>", <%= type_metatag(:request) %> do
<% namespaced_path = regular_class_path.join('/') -%>
<% if actions.empty? -%>
  describe "GET /index" do
    it "returns http success" do
      pending "add some scenarios (or delete) #{__FILE__}"
    end
  end
<% end -%>
<% for action in actions -%>
  describe "GET /<%= action %>" do
    it "returns http success" do
      get "<%= "/#{namespaced_path}" if namespaced_path != '' %>/<%= file_name %>/<%= action %>"
      expect(response).to have_http_status(:success)
    end
  end

<% end -%>
end
