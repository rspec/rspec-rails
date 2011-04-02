module RSpec::Rails::HyperShortcut
  class SubjectPlaceholder
    def initialize(group,request_pair)
      @group = group
      @request_pair = request_pair
    end

    def should(matcher_placeholder)
      behavior = Behavior.new :should, matcher_placeholder
      describe_my behavior
    end
    
    def should_not(matcher_placeholder)
      behavior = Behavior.new :should_not, matcher_placeholder
      describe_my behavior
    end

    def describe_my(behavior)
      shortcut_elements = ShortcutElements.new @request_pair, behavior
      describe_from(shortcut_elements)
    end

  private
    def describe_from(elements)
      @group.describe(elements.description)
        .it(&elements.it_block)
    end
  end
end
