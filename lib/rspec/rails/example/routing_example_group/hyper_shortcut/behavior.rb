class Behavior
  def initialize(should_or_not,matcher_placeholder)
    @should_or_not = should_or_not
    @matcher_placeholder = matcher_placeholder
  end

  def block_to_test(subject)
    block_that subject, @should_or_not, @matcher_placeholder
  end

private

  def block_that(subject,should_or_not,placeholder)
    proc do
      matcher = placeholder.build_matcher_in self
      subject.send should_or_not, matcher
    end
  end
end
