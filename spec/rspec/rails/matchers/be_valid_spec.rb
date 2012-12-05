require "spec_helper"
require 'active_support/all'

describe "be_valid matcher" do
  include RSpec::Rails::Matchers

  class TestModel
    include ActiveModel::Validations
    attr_accessor :something
    validates_presence_of :something
  end

  let(:matcher) { be_valid }
  subject { TestModel.new }

  it "includes validation errors by default" do
    matcher.matches? subject

    matcher.failure_message_for_should.should =~ /is blank/
  end
end
