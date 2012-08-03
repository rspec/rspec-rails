module RSpec::Rails::Matchers
  class HaveCallback < RSpec::Matchers::BuiltIn::BaseMatcher

    def initialize(expected)
      @expected = expected
    end

    # @api private
    def matches?(model)
      @actual = model.class
      unless @kind
        raise ArgumentError.new <<-EOM
The have_callback matcher requires its `before` or `after` method to be called:

    it { should have_callback(:punchline).before(:saving_the_day)
    it { should have_callback(:punchline).after(:saving_the_day)
EOM
      end
      @callback = "_#{@type}_callbacks"
      return false unless @actual.respond_to?(@callback)
      matches = @actual.send(@callback)
      matches.select! { |o| o.kind == @kind } if @kind
      matches.any? { |o| o.filter == @expected }
    end

    def before(type)
      @kind = :before
      @type = type
      self
    end

    def after(type)
      @kind = :after
      @type = type
      self
    end
  end

  # Passes if actual has the expected callback at the expected time.
  #
  # @example
  #
  #     class Batman
  #       extend ActiveModel::Callbacks
  #       before_saving_the_day :punchline, :only => :before
  #     end
  #     Batman.new.should have_callback(:punchline).before_saving_the_day
  def have_callback(method)
    HaveCallback.new(method)
  end
end
