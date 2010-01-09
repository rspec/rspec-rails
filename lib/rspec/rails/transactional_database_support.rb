module Rspec
  module Rails
    module TransactionalDatabaseSupport

      def active_record_configured?
        defined?(::ActiveRecord) && !::ActiveRecord::Base.configurations.blank?
      end

      def transactional_protection_start
        return unless active_record_configured?

        ::ActiveRecord::Base.connection.increment_open_transactions
        ::ActiveRecord::Base.connection.begin_db_transaction
      end

      def transactional_protection_cleanup
        return unless active_record_configured?

        if ::ActiveRecord::Base.connection.open_transactions != 0
          ::ActiveRecord::Base.connection.rollback_db_transaction
          ::ActiveRecord::Base.connection.decrement_open_transactions
        end

        ::ActiveRecord::Base.clear_active_connections!
      end

    end
  end
end

Rspec::Core.configure do |c|
  c.include Rspec::Rails::TransactionalDatabaseSupport
  c.before { transactional_protection_start }
  c.after { transactional_protection_cleanup }
end

