require 'spec_helper'
require File.dirname(__FILE__) + '/ar_classes'

describe "stub_model" do
  describe "defaults" do
    it "has an id" do
      stub_model(MockableModel).id.should be > 0
    end

    it "says it is not a new record" do
      stub_model(MockableModel).should_not be_new_record
    end
  end

  it "accepts a stub id" do
    stub_model(MockableModel, :id => 37).id.should == 37
  end

  it "says it is a new record when id is set to nil" do
    stub_model(MockableModel, :id => nil).should be_new_record
  end

  it "accepts any arbitrary stub" do
    stub_model(MockableModel, :foo => "bar").foo.should == "bar"
  end

  it "accepts a stub for save" do
    stub_model(MockableModel, :save => false).save.should be(false)
  end
  
  describe "alternate primary key" do
    it "has the correct primary_key name" do
      stub_model(AlternatePrimaryKeyModel).class.primary_key.should eql('my_id')
    end
    
    it "has a primary_key" do
      stub_model(AlternatePrimaryKeyModel).my_id.should be > 0
    end
    
    it "does not say it is a new record" do
      stub_model(AlternatePrimaryKeyModel).should_not be_new_record
    end
    
    it "says it is a new record if primary_key is nil" do
      stub_model(AlternatePrimaryKeyModel, :my_id => nil).should be_new_record
    end
    
    it "accepts a stub for the primary_key" do
      stub_model(AlternatePrimaryKeyModel, :my_id => 5).my_id.should == 5
    end
  end

  describe "#as_new_record" do
    it "says it is a new record" do
      stub_model(MockableModel).as_new_record.should be_new_record
    end

    it "has a nil id" do
      stub_model(MockableModel).as_new_record.id.should be(nil)
    end
  end

  it "raises when hitting the db" do
    lambda do
      stub_model(ConnectableModel).connection
    end.should raise_error(RSpec::Rails::IllegalDataAccessException, /stubbed models are not allowed to access the database/)
  end

  it "increments the id" do
    first = stub_model(MockableModel)
    second = stub_model(MockableModel)
    second.id.should == (first.id + 1)
  end

  describe "as association" do
    before(:each) do
      @real = AssociatedModel.create!
      @stub_model = stub_model(MockableModel)
      @real.mockable_model = @stub_model
    end

    it "passes associated_model == mock" do
        @stub_model.should == @real.mockable_model
    end

    it "passes mock == associated_model" do
        @real.mockable_model.should == @stub_model
    end
  end

  describe "with a block" do
    it "yields the model" do
      model = stub_model(MockableModel) do |block_arg|
        @block_arg = block_arg
      end
      model.should be(@block_arg)
    end
  end
end


