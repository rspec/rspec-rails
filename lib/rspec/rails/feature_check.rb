# @api private
module RSpec
  module Rails
    # Disable some cops until https://github.com/bbatsov/rubocop/issues/1310
    # rubocop:disable Style/IndentationConsistency
    module FeatureCheck
    # rubocop:disable Style/IndentationWidth
    module_function
      # rubocop:enable Style/IndentationWidth

      def can_check_pending_migrations?
        has_active_record_migration? &&
          ::ActiveRecord::Migration.respond_to?(:check_pending!)
      end

      def can_maintain_test_schema?
        has_active_record_migration? &&
          ::ActiveRecord::Migration.respond_to?(:maintain_test_schema!)
      end

      def has_active_job?
        defined?(::ActiveJob)
      end

      def has_active_record?
        defined?(::ActiveRecord)
      end

      def has_active_record_migration?
        has_active_record? && defined?(::ActiveRecord::Migration)
      end
    end
    # rubocop:enable Style/IndentationConsistency
  end
end
