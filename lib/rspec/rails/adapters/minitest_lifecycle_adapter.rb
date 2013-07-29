require 'active_support/concern'

module RSpec::Rails::Adapters
  # Minitest::Test::LifecycleHooks
  module MinitestLifecycleAdapter
    extend ActiveSupport::Concern

    included do |group|
      group.before { after_setup }
      group.after  { before_teardown }

      group.around do |example|
        before_setup
        example.run
        after_teardown
      end
    end

    def before_setup
    end

    def after_setup
    end

    def before_teardown
    end

    def after_teardown
    end
  end
end
