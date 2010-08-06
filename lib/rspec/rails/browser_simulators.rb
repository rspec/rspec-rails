module RSpec
  module Rails
    module BrowserSimulators
      extend ActiveSupport::Concern

      def self.included(mod)
        mod.instance_eval do
          def webrat(&block)
            block.call if defined?(Webrat)
          end

          def capybara(&block)
            block.call if defined?(Capybara)
          end
        end
      end

    end
  end
end