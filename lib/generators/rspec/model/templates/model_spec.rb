require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper')

describe <%= class_name %> do
  before(:each) do
    @valid_attributes = {
      <%= attributes.map{ |a| ":#{a.name} => #{a.default.inspect}" }.join(",\n      ") %>
    }
  end

  it "should create a new instance given valid attributes" do
    <%= class_name %>.create!(@valid_attributes)
  end
end
