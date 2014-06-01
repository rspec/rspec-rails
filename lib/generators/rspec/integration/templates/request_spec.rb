require 'rails_helper'

RSpec.describe "<%= class_name.pluralize %>", :type => :request do
  describe "GET /<%= table_name %>" do
    it "works! (now write some real specs)" do
      get <%= index_helper %>_path
      expect(response.status).to be(200)
    end
  end
end
