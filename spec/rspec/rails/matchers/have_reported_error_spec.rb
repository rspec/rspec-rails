require "rspec/rails/matchers/have_reported_error"

RSpec.describe "have_reported_error matcher" do
  class TestError < StandardError; end
  class AnotherTestError < StandardError; end

  it "has an reports_error alias" do
    expect {Rails.error.report(StandardError.new("test error"))}.to reports_error
  end

  it "warns that passing value expectation doesn't work" do
    expect {
      expect(Rails.error.report(StandardError.new("test error"))).to have_reported_error
    }.to raise_error(ArgumentError, "block is required for have_reported_error matcher")
  end

  describe "basic functionality" do
    it "passes when an error is reported" do
      expect {Rails.error.report(StandardError.new("test error"))}.to have_reported_error
    end

    it "fails when no error is reported" do
      expect {
        expect { "no error" }.to have_reported_error
      }.to fail_with(/Expected the block to report an error, but none was reported./)
    end

    it "passes when negated and no error is reported" do
      expect { "no error" }.not_to have_reported_error
    end
  end

  describe "error class matching" do
    it "passes when correct error class is reported" do
      expect { Rails.error.report(TestError.new("test error")) }.to have_reported_error(TestError)
    end

    it "fails when wrong error class is reported" do
      expect {
        expect {
          Rails.error.report(AnotherTestError.new("wrong error"))
        }.to have_reported_error(TestError)
      }.to fail_with(/Expected error to be an instance of TestError, but got AnotherTestError/)
    end
  end

  describe "error instance matching" do
    it "passes when error instance matches exactly" do
      expect {
        Rails.error.report(TestError.new("exact message"))
      }.to have_reported_error(TestError.new("exact message"))
    end

    it "passes when error instance has empty expected message" do
      expect {
        Rails.error.report(TestError.new("any message"))
      }.to have_reported_error(TestError.new(""))
    end

    it "fails when error instance has different message" do
      expect {
        expect {
          Rails.error.report(TestError.new("actual message"))
        }.to have_reported_error(TestError.new("expected message"))
      }.to fail_with(/Expected error to be TestError with message 'expected message', but got TestError with message: 'actual message'/)
    end
  end

  describe "regex pattern matching" do
    it "passes when error message matches pattern" do
      expect {
        Rails.error.report(StandardError.new("error with pattern"))
      }.to have_reported_error(/with pattern/)
    end

    it "fails when error message does not match pattern" do
      expect {
        expect {
          Rails.error.report(StandardError.new("error without match"))
        }.to have_reported_error(/different pattern/)
      }.to fail_with(/Expected error message to match/)
    end
  end

  describe "failure messages for attribute mismatches" do
    it "provides detailed failure message when attributes don't match" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "actual" })
        }.to have_reported_error.with(user_id: 456, context: "expected")
      }.to fail_with(/Expected error attributes to match {user_id: 456, context: "expected"}, but got these mismatches: {user_id: 456, context: "expected"} and actual values are {"user_id" => 123, "context" => "actual"}/)
    end

    it "identifies partial attribute mismatches correctly" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, status: "active", role: "admin" })
        }.to have_reported_error.with(user_id: 456, status: "active") # user_id wrong, status correct
      }.to fail_with(/got these mismatches: {user_id: 456}/)
    end

    it "handles RSpec matcher mismatches in failure messages" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { params: { foo: "different" } })
        }.to have_reported_error.with(params: a_hash_including(foo: "bar"))
      }.to fail_with(/Expected error attributes to match/)
    end

    it "shows actual context values when attributes don't match" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "actual" })
        }.to have_reported_error.with(user_id: 456)
      }.to fail_with(/actual values are {"user_id" => 123, "context" => "actual"}/)
    end
  end

  describe "attribute matching with .with chain" do
    it "passes when attributes match exactly" do
      expect {
        Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "test" })
      }.to have_reported_error.with(user_id: 123, context: "test")
    end

    it "passes with partial attribute matching" do
      expect {
        Rails.error.report(
          StandardError.new("test"), context: { user_id: 123, context: "test", extra: "data" }
        )
      }.to have_reported_error.with(user_id: 123)
    end

    it "passes with hash matching using RSpec matchers" do
      expect {
        Rails.error.report(
          StandardError.new("test"), context: { params: { foo: "bar", baz: "qux" } }
        )
      }.to have_reported_error.with(params: a_hash_including(foo: "bar"))
    end

    it "fails when attributes do not match" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "actual" })
        }.to have_reported_error.with(user_id: 456, context: "expected")
      }.to fail_with(/Expected error attributes to match {user_id: 456, context: "expected"}, but got these mismatches: {user_id: 456, context: "expected"} and actual values are {"user_id" => 123, "context" => "actual"}/)
    end

    it "fails when no error is reported but attributes are expected" do
      expect {
        expect { "no error" }.to have_reported_error.with(user_id: 123)
      }.to fail_with(/Expected the block to report an error, but none was reported./)
    end
  end

  describe "integration with actual usage patterns" do
    it "works with multiple error reports in a block" do
      expect {
        Rails.error.report(StandardError.new("first error"))
        Rails.error.report(TestError.new("second error"))
      }.to have_reported_error(StandardError)
    end

    it "works with matcher chaining" do
      expect {
        Rails.error.report(TestError.new("test"), context: { user_id: 123 })
      }.to have_reported_error(TestError).and have_reported_error
    end
  end
end
