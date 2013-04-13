require "spec_helper"

describe RSpec::Rails::MiniTestLifecycleAdapter do
  it "invokes minitest lifecycle hooks at the appropriate times" do
    invocations = []
    example_group = RSpec::Core::ExampleGroup.describe("MiniTestHooks") do
      include RSpec::Rails::MiniTestLifecycleAdapter

      define_method(:before_setup)    { invocations << :before_setup }
      define_method(:after_setup)     { invocations << :after_setup }
      define_method(:before_teardown) { invocations << :before_teardown }
      define_method(:after_teardown)  { invocations << :after_teardown }
    end

    example = example_group.example("foo") { invocations << :example }
    example_group.run(NullObject.new)

    expect(invocations).to eq([
      :before_setup, :after_setup, :example, :before_teardown, :after_teardown
    ])
  end
end
