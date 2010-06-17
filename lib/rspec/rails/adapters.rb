require 'active_support/concern'
require 'test/unit/assertions'

module RSpec
  module Rails
    module SetupAndTeardownAdapter
      extend ActiveSupport::Concern

      module ClassMethods
        def setup(*methods)
          methods.each {|method| before { send method } }
        end

        def teardown(*methods)
          methods.each {|method| after { send method } }
        end
      end
    end

    module TestUnitAssertionAdapter
      extend ActiveSupport::Concern
      def method_name
        @example
      end

      include Test::Unit::Assertions

      included do
        before do
          @_result = Struct.new(:add_assertion).new
        end
      end
    end
  end
end
