require "spec_helper"

describe "errors_on" do
  let(:klass) do
    Class.new do
      include ActiveModel::Validations
    end
  end

  it "calls valid?" do
    model = klass.new
    expect(model).to receive(:valid?)
    model.errors_on(:foo)
  end

  it "returns the errors on that attribute" do
    model = klass.new
    allow(model).to receive(:errors) do
      { :foo => ['a', 'b'] }
    end
    expect(model.errors_on(:foo)).to eq(['a','b'])
  end
end
