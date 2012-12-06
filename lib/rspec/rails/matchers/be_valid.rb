module RSpec::Rails::Matchers
  class BeValid < RSpec::Matchers::BuiltIn::Be
    def match(_, actual)
      actual.valid?
    end

    def failure_message_for_should
      messages = actual.errors.full_messages.join(', ')
      "expected #{actual} to be valid (#{messages})"
    end

    def failure_message_for_should_not
      "expected #{actual} to not be valid"
    end
  end

  # Passes if the given model instance's `valid?` method
  # is true, meaning all of the `ActiveModel::Validations`
  # passed and no errors exist. If a message is not
  # given, a default message is shown listing each error.
  #
  # @example
  #
  #     thing = Thing.new
  #
  #     thing.should be_valid
  def be_valid
    BeValid.new
  end
end
