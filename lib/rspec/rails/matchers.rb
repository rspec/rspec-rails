require 'rspec/matchers'

begin
  require 'test/unit/assertionfailederror'
rescue LoadError
  module Test
    module Unit
      class AssertionFailedError < StandardError
      end
    end
  end
end

module Rspec
  module Rails
    module Matchers
      include Rspec::Matchers

      def redirect_to(destination)
        running_example = self
        Matcher.new :redirect_to, destination do |destination_|
          match_unless_raises Test::Unit::AssertionFailedError do |_|
            running_example.assert_redirected_to destination_
          end
        end
      end

      def render_template(options={}, message=nil)
        running_example = self
        Matcher.new :render_template, options, message do |options_, message_|
          match_unless_raises Test::Unit::AssertionFailedError do |_|
            running_example.assert_template options_, message_
          end
        end
      end

    end
  end
end

Rspec::Matchers.define :be_a_new do |model_klass|
  match do |actual|
    model_klass === actual && actual.new_record?
  end
end
