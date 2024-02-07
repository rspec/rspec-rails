require 'rails_helper'

RSpec.describe "<%= class_name.pluralize %>" do
  describe "GET /<%= name.underscore.pluralize %>" do
    it "works! (now write some real specs)" do
      get <%= index_helper %>_path
      expect(response).to have_http_status(200)
    end
  end
end
