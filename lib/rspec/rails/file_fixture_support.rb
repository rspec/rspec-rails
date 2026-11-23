require 'active_support/testing/file_fixtures'

module RSpec
  module Rails
    # @private
    module FileFixtureSupport
      extend ActiveSupport::Concern
      include ActiveSupport::Testing::FileFixtures

      included do
        self.file_fixture_path = FileFixtureSupport.expanded_fixture_path
        if defined?(ActiveStorage::FixtureSet)
          ActiveStorage::FixtureSet.file_fixture_path = FileFixtureSupport.expanded_fixture_path
        end
      end

      # Expand the configured `file_fixture_path` against `Rails.root` so the
      # value made available to example groups is absolute, matching how
      # `ActiveSupport::TestCase` configures it. `File.expand_path` is a no-op
      # when the path is already absolute, so user-supplied absolute paths are
      # passed through unchanged.
      def self.expanded_fixture_path
        File.expand_path(RSpec.configuration.file_fixture_path, ::Rails.root)
      end
    end
  end
end
