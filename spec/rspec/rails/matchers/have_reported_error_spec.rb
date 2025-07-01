RSpec.describe "have_reported_error matcher" do
  class TestError < StandardError; end
  class AnotherTestError < StandardError; end

  it "is aliased as reports_error" do
    expect {Rails.error.report(StandardError.new("test error"))}.to reports_error
  end

  it "warns when used as a value expectation" do
    expect {
      expect(Rails.error.report(StandardError.new("test error"))).to have_reported_error
    }.to raise_error(ArgumentError, "this matcher doesn't work with value expectations")
  end

  context "without constraint" do
    it "passes when an error is reported" do
      expect {Rails.error.report(StandardError.new("test error"))}.to have_reported_error
    end

    it "fails when no errors are reported" do
      expect {
        expect { "no error" }.to have_reported_error
      }.to fail_with(/Expected the block to report an error, but none was reported./)
    end

    it "passes when negated and no errors are reported" do
      expect { "no error" }.not_to have_reported_error
    end
  end

  context "constrained to a specific error class" do
    it "passes when an error with the correct class is reported" do
      expect { Rails.error.report(TestError.new("test error")) }.to have_reported_error(TestError)
    end

    it "fails when an error with the wrong class is reported" do
      expect {
        expect {
          Rails.error.report(AnotherTestError.new("wrong error"))
        }.to have_reported_error(TestError)
      }.to fail_with(/Expected error to be an instance of TestError, but got AnotherTestError/)
    end
  end

  context "constrained to a matching error (class and message)" do
    it "passes with an error that matches exactly" do
      expect {
        Rails.error.report(TestError.new("exact message"))
      }.to have_reported_error(TestError, "exact message")
    end

    it "passes any error of the same class if no message is specified" do
      expect {
        Rails.error.report(TestError.new("any message"))
      }.to have_reported_error(TestError)
    end

    it "fails when the error has different message to the expected" do
      expect {
        expect {
          Rails.error.report(TestError.new("actual message"))
        }.to have_reported_error(TestError, "expected message")
      }.to fail_with(/Expected error message to be 'expected message', but got: 'actual message'/)
    end
  end

  context "constrained by regex pattern matching" do
    it "passes when an error message matches the pattern" do
      expect {
        Rails.error.report(StandardError.new("error with pattern"))
      }.to have_reported_error(StandardError, /with pattern/)
    end

    it "fails when no error messages match the pattern" do
      expect {
        expect {
          Rails.error.report(StandardError.new("error without match"))
        }.to have_reported_error(StandardError, /different pattern/)
      }.to fail_with(/Expected error message to match/)
    end
  end

  describe "#failure_message" do
    it "provides details about mismatched attributes" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "actual" })
        }.to have_reported_error.with_context(user_id: 456, context: "expected")
      }.to fail_with(/Expected error attributes to match {user_id: 456, context: "expected"}, but got these mismatches: {user_id: 456, context: "expected"} and actual values are {"user_id" => 123, "context" => "actual"}/)
    end

    it "identifies partial attribute mismatches correctly" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, status: "active", role: "admin" })
        }.to have_reported_error.with_context(user_id: 456, status: "active") # user_id wrong, status correct
      }.to fail_with(/got these mismatches: {user_id: 456}/)
    end

    it "handles RSpec matcher mismatches in failure messages" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { params: { foo: "different" } })
        }.to have_reported_error.with_context(params: a_hash_including(foo: "bar"))
      }.to fail_with(/Expected error attributes to match/)
    end

    it "shows actual context values when attributes don't match" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "actual" })
        }.to have_reported_error.with_context(user_id: 456)
      }.to fail_with(/actual values are {"user_id" => 123, "context" => "actual"}/)
    end
  end

  describe "#with_context" do
    it "passes when attributes match exactly" do
      expect {
        Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "test" })
      }.to have_reported_error.with_context(user_id: 123, context: "test")
    end

    it "passes with partial attribute matching" do
      expect {
        Rails.error.report(
          StandardError.new("test"), context: { user_id: 123, context: "test", extra: "data" }
        )
      }.to have_reported_error.with_context(user_id: 123)
    end

    it "passes with hash matching using RSpec matchers" do
      expect {
        Rails.error.report(
          StandardError.new("test"), context: { params: { foo: "bar", baz: "qux" } }
        )
      }.to have_reported_error.with_context(params: a_hash_including(foo: "bar"))
    end

    it "fails when attributes do not match" do
      expect {
        expect {
          Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "actual" })
        }.to have_reported_error.with_context(user_id: 456, context: "expected")
      }.to fail_with(/Expected error attributes to match {user_id: 456, context: "expected"}, but got these mismatches: {user_id: 456, context: "expected"} and actual values are {"user_id" => 123, "context" => "actual"}/)
    end

    it "fails when no error is reported but attributes are expected" do
      expect {
        expect { "no error" }.to have_reported_error.with_context(user_id: 123)
      }.to fail_with(/Expected the block to report an error, but none was reported./)
    end
  end

  context "constrained by message only" do
    it "passes when any error with exact message is reported" do
      expect {
        Rails.error.report(StandardError.new("exact message"))
      }.to have_reported_error("exact message")
    end

    it "passes when any error with message matching pattern is reported" do
      expect {
        Rails.error.report(AnotherTestError.new("error with pattern"))
      }.to have_reported_error(/with pattern/)
    end

    it "fails when no error with exact message is reported" do
      expect {
        expect {
          Rails.error.report(StandardError.new("actual message"))
        }.to have_reported_error("expected message")
      }.to fail_with(/Expected error message to be 'expected message', but got: 'actual message'/)
    end

    it "fails when no error with matching pattern is reported" do
      expect {
        expect {
          Rails.error.report(StandardError.new("error without match"))
        }.to have_reported_error(/different pattern/)
      }.to fail_with(/Expected error message to match/)
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
        expect {
          Rails.error.report(TestError.new("test"))
        }.to have_reported_error(TestError).and have_reported_error
      }.to raise_error(ArgumentError, "Chaining is not supported")
    end
  end
end
