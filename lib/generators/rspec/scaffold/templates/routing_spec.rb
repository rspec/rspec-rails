require "spec_helper"

describe <%= controller_class_name %>Controller do
  describe "routing" do

<% unless options[:singleton] -%>
    it "recognizes and generates #index" do
      get("/<%= table_name %>").should route_to("<%= table_name %>#index")
    end

<% end -%>
    it "recognizes and generates #new" do
      get("/<%= table_name %>/new").should route_to("<%= table_name %>#new")
    end

    it "recognizes and generates #show" do
      get("/<%= table_name %>/1").should route_to("<%= table_name %>#show", :id => "1")
    end

    it "recognizes and generates #edit" do
      get("/<%= table_name %>/1/edit").should route_to("<%= table_name %>#edit", :id => "1")
    end

    it "recognizes and generates #create" do
      post("/<%= table_name %>").should route_to("<%= table_name %>#create")
    end

    it "recognizes and generates #update" do
      put("/<%= table_name %>/1").should route_to("<%= table_name %>#update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      delete("/<%= table_name %>/1").should route_to("<%= table_name %>#destroy", :id => "1")
    end

  end
end
