require "spec_helper"
require 'active_support/all'
require 'rspec/rails/matchers/be_valid'

describe "be_valid matcher" do
  include RSpec::Rails::Matchers

  class Post
    include ActiveModel::Validations
    attr_accessor :title
    validates_presence_of :title
  end

  let(:post) { Post.new }

  it "includes the error messages in the failure message" do
    expect {
      expect(post).to be_valid
    }.to raise_exception(/Title can't be blank/)
  end

  it "includes a failure message for the negative case" do
    post.stub(:valid?) { true }
    expect {
      expect(post).not_to be_valid
    }.to raise_exception(/expected .* not to be valid/)
  end

  it "uses a custom failure message if provided" do
    expect {
      expect(post).to be_valid, "Post was not valid!"
    }.to raise_exception(/Post was not valid!/)
  end

  it "includes the validation context if provided" do
    post.should_receive(:valid?).with(:create) { true }
    expect(post).to be_valid(:create)
  end

  it "does not include the validation context if not provided" do
    post.should_receive(:valid?).with(no_args) { true }
    expect(post).to be_valid
  end
end
