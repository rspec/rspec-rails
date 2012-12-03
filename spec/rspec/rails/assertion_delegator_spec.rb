require "spec_helper"

describe RSpec::Rails::AssertionDelegator do
  it "provides a module that delegates assertion methods to an isolated class" do
    klass = Class.new {
      include RSpec::Rails::AssertionDelegator.new(Test::Unit::Assertions)
    }

    expect(klass.new).to respond_to(:assert)
  end

  it "delegates back to the including instance for methods the assertion module requires" do
    assertions = Module.new {
      def has_thing?(thing)
        self.things.include?(thing)
      end
    }

    klass = Class.new {
      include RSpec::Rails::AssertionDelegator.new(assertions)

      def things
        [:a]
      end
    }

    expect(klass.new).to have_thing(:a)
    expect(klass.new).not_to have_thing(:b)
  end
end
