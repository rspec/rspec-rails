module Rspec
  module Mocks
    module ExampleMethods
      include Rspec::Mocks::ArgumentMatchers

      # Shortcut for creating an instance of Rspec::Mocks::Mock.
      #
      # +name+ is used for failure reporting, so you should use the
      # role that the mock is playing in the example.
      #
      # +stubs_and_options+ lets you assign options and stub values
      # at the same time. The only option available is :null_object.
      # Anything else is treated as a stub value.
      #
      # == Examples
      #
      #   stub_thing = mock("thing", :a => "A")
      #   stub_thing.a == "A" => true
      #
      #   stub_person = stub("thing", :name => "Joe", :email => "joe@domain.com")
      #   stub_person.name => "Joe"
      #   stub_person.email => "joe@domain.com"
      def mock(*args)
        Rspec::Mocks::Mock.new(*args)
      end

      alias :stub :mock

      # Disables warning messages about expectations being set on nil.
      #
      # By default warning messages are issued when expectations are set on nil.  This is to
      # prevent false-positives and to catch potential bugs early on.
      def allow_message_expectations_on_nil
        Proxy.allow_message_expectations_on_nil
      end

    end
  end
end
