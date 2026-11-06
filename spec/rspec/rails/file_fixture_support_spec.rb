module RSpec::Rails
  RSpec.describe FileFixtureSupport, :with_isolated_config do
    it "expands a relative configured file_fixture_path against Rails.root" do
      RSpec.configuration.file_fixture_path = 'spec/fixtures/files'

      group = RSpec::Core::ExampleGroup.describe do
        include FileFixtureSupport
      end

      expect(group.file_fixture_path)
        .to eq(File.expand_path('spec/fixtures/files', ::Rails.root))
    end

    it "passes through an absolute configured file_fixture_path unchanged" do
      absolute_path = File.expand_path('/tmp/custom/fixtures')
      RSpec.configuration.file_fixture_path = absolute_path

      group = RSpec::Core::ExampleGroup.describe do
        include FileFixtureSupport
      end

      expect(group.file_fixture_path).to eq(absolute_path)
    end

    if defined?(ActiveStorage::FixtureSet)
      it "applies the expanded path to ActiveStorage::FixtureSet" do
        RSpec.configuration.file_fixture_path = 'spec/fixtures/files'

        RSpec::Core::ExampleGroup.describe do
          include FileFixtureSupport
        end

        expect(ActiveStorage::FixtureSet.file_fixture_path)
          .to eq(File.expand_path('spec/fixtures/files', ::Rails.root))
      end
    end
  end
end
