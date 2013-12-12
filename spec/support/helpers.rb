module Helpers
  def stub_metadata(additional_metadata)
    stub_metadata = metadata_with(additional_metadata)
    allow(RSpec::Core::ExampleGroup).to receive(:metadata) { stub_metadata }
  end

  def metadata_with(additional_metadata)
    m = RSpec::Core::Metadata.new
    m.process("example group")

    group_metadata = additional_metadata.delete(:example_group)
    if group_metadata
      m[:example_group].merge!(group_metadata)
    end
    m.merge!(additional_metadata)
    m
  end

  def with_isolated_config
    original_config = RSpec.configuration
    RSpec.configuration = RSpec::Core::Configuration.new
    RSpec.configure do |c|
      c.include RSpec::Rails::FixtureSupport
      c.add_setting :use_transactional_fixtures, :alias_with => :use_transactional_examples
      c.add_setting :use_instantiated_fixtures
      c.add_setting :global_fixtures
      c.add_setting :fixture_path
    end
    yield
    RSpec.configuration = original_config
  end

  RSpec.configure {|c| c.include self}
end
