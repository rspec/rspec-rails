require "spec_helper"
require 'active_support/all'

describe "be_valid matcher" do
  include RSpec::Rails::Matchers

  class TestModel
    include ActiveModel::Validations
    attr_accessor :something
    validates_presence_of :something
  end

  subject { TestModel.new }

  it "passes the matcher when valid" do
    subject.something = "something"

    subject.should be_valid
    expect(subject).to be_valid
  end

  it "fails the matcher when not valid" do
    subject.something = nil

    subject.should_not be_valid
    expect(subject).to_not be_valid
  end
end
