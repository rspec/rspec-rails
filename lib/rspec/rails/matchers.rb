require 'rspec/matchers'

module Rspec
  module Rails
    module Matchers
      def redirect_to(destination)
        example = self
        Rspec::Matchers::Matcher.new :redirect_to, destination do |destination_|
          match do |_|
            example.assert_redirected_to destination_
          end
        end
      end
    end
  end
end
