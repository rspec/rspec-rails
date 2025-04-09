module RSpec
  module Rails
    # @private
    module FileFixtureUploadSupport
      if ::Rails::VERSION::STRING < "7.1.0"
        delegate :fixture_file_upload, to: :rails_file_fixture_wrapper
      else
        delegate :file_fixture_upload, :fixture_file_upload, to: :rails_file_fixture_wrapper
      end

    private

      # In Rails 7.0 fixture file path needs to be relative to `file_fixture_path` instead, this change
      # was brought in with a deprecation warning on 6.1. In Rails 7.0 expect to rework this to remove
      # the old accessor.
      def rails_file_fixture_wrapper
        RailsFileFixtureWrapper.file_fixture_path = nil
        resolved_fixture_path =
          if respond_to?(:file_fixture_path) && !file_fixture_path.nil?
            file_fixture_path.to_s
          elsif respond_to?(:fixture_paths)
            (RSpec.configuration.fixture_paths&.first || '').to_s
          else
            (RSpec.configuration.fixture_path || '').to_s
          end
        RailsFileFixtureWrapper.file_fixture_path = File.join(resolved_fixture_path, '') unless resolved_fixture_path.strip.empty?
        RailsFileFixtureWrapper.instance
      end

      class RailsFileFixtureWrapper
        include ActionDispatch::TestProcess if defined?(ActionDispatch::TestProcess)
        include ActiveSupport::Testing::FileFixtures

        class << self
          if ::Rails::VERSION::STRING < "7.1.0"
            attr_accessor :fixture_path
          else
            attr_accessor :fixture_paths
          end

          # Get instance of wrapper
          def instance
            @instance ||= new
          end
        end
      end
    end
  end
end
