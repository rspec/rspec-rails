module RSpec
  module Rails
    # @private
    module FixtureFileUploadSupport
      delegate :fixture_file_upload, to: :rails_fixture_file_wrapper

    private

      def rails_fixture_file_wrapper
        RailsFixtureFileWrapper.fixture_path = nil
        resolved_fixture_path =
          if respond_to?(:fixture_path) && !fixture_path.nil?
            fixture_path.to_s
          else
            (RSpec.configuration.fixture_path || '').to_s
          end
        RailsFixtureFileWrapper.fixture_path = File.join(resolved_fixture_path, '') unless resolved_fixture_path.strip.empty?
        RailsFixtureFileWrapper.instance
      end

      class RailsFixtureFileWrapper
        include ActionDispatch::TestProcess if defined?(ActionDispatch::TestProcess)

        class << self
          attr_accessor :fixture_path

          # Get instance of wrapper
          def instance
            @instance ||= new
          end
        end
      end
    end
  end
end
