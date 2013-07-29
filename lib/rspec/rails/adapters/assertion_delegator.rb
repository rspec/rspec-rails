require 'delegate'

module RSpec::Rails::Adapters
  class AssertionDelegator < Module
    # @api private
    def initialize(*assertion_modules)
      assertion_class = Class.new(SimpleDelegator) do
        include ::RSpec::Rails::Adapters::Assertions
        include ::RSpec::Rails::Adapters::MinitestCounters
        assertion_modules.each { |mod| include mod }
      end

      super() do
        # @api private
        define_method :build_assertion_instance do
          assertion_class.new(self)
        end

        # @api private
        def assertion_instance
          @assertion_instance ||= build_assertion_instance
        end

        assertion_modules.each do |mod|
          mod.public_instance_methods.each do |method|
            next if method == :method_missing || method == "method_missing"
            class_eval <<-EOM, __FILE__, __LINE__ + 1
                  def #{method}(*args, &block)
                    assertion_instance.send(:#{method}, *args, &block)
                  end
            EOM
          end
        end
      end
    end
  end
end
