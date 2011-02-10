require "spec_helper"

describe "error_messages_on" do
  let(:klass) do
    Class.new do
      include ActiveModel::Validations
    end
  end

  it "calls valid?" do
    model = klass.new
    model.should_receive(:valid?)
    model.errors_on(:foo)
  end

  it "returns nil on attribute when the entire model is valid" do
    model = klass.new
    model.error_message_on(:bar).should be_nil
    model.error_message_on(:bar).should be_blank
  end

  it "returns nil on attribute when model is invalid but this attribute is valid" do
    model = klass.new
    model.stub(:errors) do
      { :foo => ['a'], :bar => [] }
    end
    model.error_message_on(:bar).should be_nil
    model.error_message_on(:bar).should be_blank
  end

  it "returns error message on attribute when there is one error message for it" do
    model = klass.new
    model.stub(:errors) do
      { :foo => ['a'] }
    end
    model.error_message_on(:foo).should == 'a'
  end

  it "returns error message array on attribute when there are two error messages for it" do
    model = klass.new
    model.stub(:errors) do
      { :foo => ['a', 'b'] }
    end
    model.error_messages_on(:foo).should eq(['a','b'])
  end

  it "returns error message array on attribute when there are more than two error messages for it" do
    model = klass.new
    model.stub(:errors) do
      { :foo => ['a', 'b', 'c'] }
    end
    model.error_messages_on(:foo).should eq(['a','b','c'])
  end

end
