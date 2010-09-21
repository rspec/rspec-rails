require 'spec_helper'
require File.dirname(__FILE__) + '/mongoid_classes'

describe "stub_model" do
  describe "defaults" do
    it "says it is not a new record" do
      stub_model(MongoidMockableModel).should_not be_new_record
    end
  end

  it "accepts any arbitrary stub" do
    stub_model(MongoidMockableModel, :foo => "bar").foo.should == "bar"
  end

  it "accepts a stub for save" do
    stub_model(MongoidMockableModel, :save => false).save.should be(false)
  end
  
  describe "#as_new_record" do
    it "says it is a new record" do
      stub_model(MongoidMockableModel).as_new_record.should be_new_record
    end
  end

  describe "as association" do
    before(:each) do
      @real = MongoidAssociatedModel.create!
      @stub_model = stub_model(MongoidMockableModel)
      @real.mongoid_mockable_model = @stub_model
    end

    it "passes associated_model == mock" do
      @stub_model.should == @real.mongoid_mockable_model
    end

    it "passes mock == associated_model" do
      @real.mongoid_mockable_model.should == @stub_model
    end
  end

  describe "with a block" do
    it "yields the model" do
      model = stub_model(MongoidMockableModel) do |block_arg|
        @block_arg = block_arg
      end
      model.should be(@block_arg)
    end
  end
end
