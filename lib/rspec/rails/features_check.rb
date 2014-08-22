module RSpec
  module Rails
    module FeaturesCheck
      module_function

      def has_activejob?
        defined?(::ActiveJob)
      end
    end
  end
end
