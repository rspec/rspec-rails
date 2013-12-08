require "spec_helper"

describe "error_on" do
  it "provides a description including the name of what the error is on" do
    expect(have(1).error_on(:whatever).description).to eq("have 1 error on :whatever")
  end

  it "provides a failure message including the number actually given" do
    expect {
      expect([]).to have(1).error_on(:whatever)
    }.to raise_error("expected 1 error on :whatever, got 0")
  end
end

describe "errors_on" do
  it "provides a description including the name of what the error is on" do
    expect(have(2).errors_on(:whatever).description).to eq("have 2 errors on :whatever")
  end

  it "provides a failure message including the number actually given" do
    expect {
      expect([1]).to have(3).errors_on(:whatever)
    }.to raise_error("expected 3 errors on :whatever, got 1")
  end
end

describe "have something other than error_on or errors_on" do
  it "has a standard rspec failure message" do
    expect {
      expect([1,2,3]).to have(2).elements
    }.to raise_error("expected 2 elements, got 3")
  end

  it "has a standard rspec description" do
    expect(have(2).elements.description).to eq("have 2 elements")
  end
end

