require "rspec/rails/matchers/have_reported_error"

RSpec.describe "have_reported_error matcher" do
  class TestError < StandardError; end
  class AnotherTestError < StandardError; end

  describe "basic functionality" do
    it "passes when an error is reported" do
      test_block = proc do
        Rails.error.report(StandardError.new("test error"))
      end

      expect(test_block).to have_reported_error
    end

    it "fails when no error is reported" do
      test_block = proc { "no error" }
      matcher = have_reported_error

      expect(matcher.matches?(test_block)).to be false
    end

    it "passes when negated and no error is reported" do
      test_block = proc { "no error" }

      expect(test_block).not_to have_reported_error
    end
  end

  describe "error class matching" do
    it "passes when correct error class is reported" do
      test_block = proc do
        Rails.error.report(TestError.new("test error"))
      end

      expect(test_block).to have_reported_error(TestError)
    end

    it "fails when wrong error class is reported" do
      test_block = proc do
        Rails.error.report(AnotherTestError.new("wrong error"))
      end
      matcher = have_reported_error(TestError)

      expect(matcher.matches?(test_block)).to be false
    end
  end

  describe "error instance matching" do
    it "passes when error instance matches exactly" do
      expected_error = TestError.new("exact message")
      test_block = proc do
        Rails.error.report(TestError.new("exact message"))
      end

      expect(test_block).to have_reported_error(expected_error)
    end

    it "passes when error instance has empty expected message" do
      expected_error = TestError.new("")
      test_block = proc do
        Rails.error.report(TestError.new("any message"))
      end

      expect(test_block).to have_reported_error(expected_error)
    end

    it "fails when error instance has different message" do
      expected_error = TestError.new("expected message")
      test_block = proc do
        Rails.error.report(TestError.new("actual message"))
      end
      matcher = have_reported_error(expected_error)

      expect(matcher.matches?(test_block)).to be false
    end
  end

  describe "regex pattern matching" do
    it "passes when error message matches pattern" do
      test_block = proc do
        Rails.error.report(StandardError.new("error with pattern"))
      end

      expect(test_block).to have_reported_error(/with pattern/)
    end

    it "fails when error message does not match pattern" do
      test_block = proc do
        Rails.error.report(StandardError.new("error without match"))
      end
      matcher = have_reported_error(/different pattern/)

      expect(matcher.matches?(test_block)).to be false
    end
  end

  describe "attribute matching with .with chain" do
    it "passes when attributes match exactly" do
      test_block = proc do
        Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "test" })
      end

      expect(test_block).to have_reported_error.with(user_id: 123, context: "test")
    end

    it "passes with partial attribute matching" do
      test_block = proc do
        Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "test", extra: "data" })
      end

      expect(test_block).to have_reported_error.with(user_id: 123)
    end

    it "passes with hash matching using RSpec matchers" do
      test_block = proc do
        Rails.error.report(StandardError.new("test"), context: { params: { foo: "bar", baz: "qux" } })
      end

      expect(test_block).to have_reported_error.with(params: a_hash_including(foo: "bar"))
    end

    it "fails when attributes do not match" do
      test_block = proc do
        Rails.error.report(StandardError.new("test"), context: { user_id: 123, context: "actual" })
      end
      matcher = have_reported_error.with(user_id: 456, context: "expected")

      expect(matcher.matches?(test_block)).to be false
    end

    it "fails when no error is reported but attributes are expected" do
      test_block = proc { "no error" }
      matcher = have_reported_error.with(user_id: 123)

      expect(matcher.matches?(test_block)).to be false
    end
  end

  describe "cleanup behavior" do
    it "unsubscribes from error reporter on successful completion" do
      test_block = proc do
        Rails.error.report(StandardError.new("test"))
      end

      expect(test_block).to have_reported_error
    end

    it "unsubscribes from error reporter even when exception is raised" do
      test_block = proc do
        Rails.error.report(StandardError.new("test"))
        raise "unexpected error"
      end

      expect {
        have_reported_error.matches?(test_block)
      }.to raise_error("unexpected error")
    end
  end

  describe "block expectations support" do
    it "declares support for block expectations" do
      matcher = have_reported_error
      expect(matcher).to respond_to(:supports_block_expectations?)
      expect(matcher.supports_block_expectations?).to be true
    end
  end

  describe "integration with actual usage patterns" do
    it "works with multiple error reports in a block" do
      test_block = proc do
        Rails.error.report(StandardError.new("first error"))
        Rails.error.report(TestError.new("second error"))
      end

      expect(test_block).to have_reported_error(StandardError)
    end

    it "works with matcher chaining" do
      test_block = proc do
        Rails.error.report(TestError.new("test"), context: { user_id: 123 })
      end

      expect(test_block).to have_reported_error(TestError).and have_reported_error
    end
  end
end
