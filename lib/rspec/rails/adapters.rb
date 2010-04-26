require 'active_support/concern'
require 'test/unit/assertions'

module Rspec
  module Rails
    module SetupAndTeardownAdapter
      def setup(*methods)
        methods.each {|method| before { send method } }
      end

      def teardown(*methods)
        methods.each {|method| after { send method } }
      end
    end

    module TestUnitAssertionAdapter
      extend ActiveSupport::Concern

      included do
        include Test::Unit::Assertions

        before do
          @_result = Struct.new(:add_assertion).new
        end
      end
    end
  end
end
