require 'spec_helper'

module RSpec::Rails
  describe FixtureFileUploadSupport do
    context 'with fixture path set in config' do
      before { RSpec.configuration.fixture_path = File.dirname(__FILE__) }

      it 'resolves fixture file' do
        expect(fixture_file_upload_resolved('fixture_file_upload_support_spec.rb').run).to be true
      end
    end

    context 'with fixture path set in spec' do
      it 'resolves fixture file' do
        expect(fixture_file_upload_resolved('fixture_file_upload_support_spec.rb', File.dirname(__FILE__)).run).to be true
      end
    end

    context 'with fixture path not set' do
      before { RSpec.configuration.fixture_path = nil }

      it 'resolves fixture with relative path' do
        expect(fixture_file_upload_resolved('fixture_file_upload_support_spec.rb').run).to be true
      end
    end

    def fixture_file_upload_resolved(fixture_name, fixture_path = nil)
      RSpec::Core::ExampleGroup.describe do
        include RSpec::Rails::FixtureFileUploadSupport

        self.fixture_path = fixture_path if fixture_path

        it 'supports fixture file upload' do
          file = fixture_file_upload(fixture_name)
          expect(file.read).to match(/describe FixtureFileUploadSupport/im)
        end
      end
    end
  end
end
