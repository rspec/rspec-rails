module RSpec::Rails::Matchers
  class BeValid < RSpec::Matchers::BuiltIn::BeTrue
    def match(_, actual)
      actual.valid?
    end

    def failure_message_for_should
      messages = actual.errors.full_messages.join(', ')
      "expected #{actual} to be valid (#{messages}" if actual.valid?
    end

    def failure_message_for_should_not
      "expected #{actual} to not be valid"
    end
  end
end
