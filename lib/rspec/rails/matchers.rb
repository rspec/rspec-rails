require 'rspec/matchers'
require 'test/unit/assertionfailederror'

module Rspec
  module Rails
    module Matchers
      include Rspec::Matchers

      def redirect_to(destination)
        example = self
        Matcher.new :redirect_to, destination do |destination_|
          match_unless_raises Test::Unit::AssertionFailedError do |_|
            example.assert_redirected_to destination_
          end
        end
      end

      def render_template(options={}, message=nil)
        example = self
        Matcher.new :render_template, options, message do |options_, message_|
          match_unless_raises Test::Unit::AssertionFailedError do |_|
            example.assert_template options_, message_
          end
        end
      end
    end
  end
end
