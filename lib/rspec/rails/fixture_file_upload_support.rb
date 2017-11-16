module RSpec
  module Rails
    # @private
    module FixtureFileUploadSupport

      def self.included(other)
        other.include ActionDispatch::TestProcess if defined?(ActionDispatch::TestProcess)
      end

      def fixture_file_upload(*args)
        if ActionController::TestCase.respond_to?(:fixture_path)
          resolved_fixture_path = (fixture_path || RSpec.configuration.fixture_path || '')
          ActionController::TestCase.fixture_path = File.join(resolved_fixture_path, '')
        end

        super
      end

    end
  end
end
