module RSpec
  module Rails
    module TransactionalDatabaseSupport

      def active_record_configured?
        defined?(::ActiveRecord) && !::ActiveRecord::Base.configurations.blank?
      end

      def use_transactional_examples?
        active_record_configured? && RSpec.configuration.use_transactional_examples?
      end

      def setup_transactional_examples
        return unless use_transactional_examples?

        ::ActiveRecord::Base.connection.increment_open_transactions
        ::ActiveRecord::Base.connection.begin_db_transaction
      end

      def teardown_transactional_examples
        return unless use_transactional_examples?

        if ::ActiveRecord::Base.connection.open_transactions != 0
          ::ActiveRecord::Base.connection.rollback_db_transaction
          ::ActiveRecord::Base.connection.decrement_open_transactions
        end

        ::ActiveRecord::Base.clear_active_connections!
      end

    end
  end
end

RSpec.configure do |c|
  c.include RSpec::Rails::TransactionalDatabaseSupport
  c.before { setup_transactional_examples }
  c.after  { teardown_transactional_examples }
end

