require "spec_helper"

describe RSpec::Rails::AssertionDelegator do
  it "provides a module that delegates assertion methods to an isolated class" do
    klass = Class.new do
      include RSpec::Rails::AssertionDelegator.new(RSpec::Rails::Assertions)
    end

    expect(klass.new).to respond_to(:assert)
  end

  it "delegates back to the including instance for methods the assertion module requires" do
    assertions = Module.new do
      def has_thing?(thing)
        things.include?(thing)
      end
    end

    klass = Class.new do
      include RSpec::Rails::AssertionDelegator.new(assertions)

      def things
        [:a]
      end
    end

    expect(klass.new).to have_thing(:a)
    expect(klass.new).not_to have_thing(:b)
  end

  it "does not delegate method_missing" do
    assertions = Module.new do
      def method_missing(_method, *_args)
      end
    end

    klass = Class.new do
      include RSpec::Rails::AssertionDelegator.new(assertions)
    end

    expect { klass.new.abc123 }.to raise_error(NoMethodError)
  end
end
