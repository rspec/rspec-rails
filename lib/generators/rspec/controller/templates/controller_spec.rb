require 'spec_helper'

describe <%= class_name %>Controller do

<% for action in actions -%>
  describe "GET '<%= action %>'" do
    it "returns http success" do
      get '<%= action %>'
      response.should be_success
    end
  end

<% end -%>
end
