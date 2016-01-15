require "spec_helper"

describe RSpec::Rails::MinitestAssertionAdapter do
  include RSpec::Rails::MinitestAssertionAdapter

  RSpec::Rails::Assertions.public_instance_methods.select{|m| m.to_s =~ /^(assert|flunk|refute)/}.each do |m|
    if m.to_s == "assert_equal"
      it "exposes #{m} to host examples" do
        assert_equal 3,3
        expect do
          assert_equal 3,4
        end.to raise_error(ActiveSupport::TestCase::Assertion)
      end
    else
      it "exposes #{m} to host examples" do
        expect(methods).to include(m)
      end
    end
  end

  it "does not expose internal methods of Minitest" do
    expect(methods).not_to include("_assertions")
  end

  it "does not expose Minitest's message method" do
    expect(methods).not_to include("message")
  end

  if ::Rails::VERSION::STRING >= '4.0.0'
    # In Ruby <= 1.8.7 Object#methods returns Strings instead of Symbols. They
    # are all converted to Symbols to ensure we always compare them correctly.
    it 'does not leak TestUnit specific methods into the AssertionDelegator' do
      expect(methods.map(&:to_sym)).to_not include(:build_message)
    end
  else
    it 'includes methods required by TestUnit into the AssertionDelegator' do
      expect(methods.map(&:to_sym)).to include(:build_message)
    end
  end
end
