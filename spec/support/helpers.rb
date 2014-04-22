module Helpers
  def stub_metadata(additional_metadata)
    stub_metadata = metadata_with(additional_metadata)
    allow(RSpec::Core::ExampleGroup).to receive(:metadata) { stub_metadata }
  end

  def metadata_with(additional_metadata)
    ::RSpec.describe("example group").metadata.merge(additional_metadata)
  end

  def with_isolated_config
    original_config = RSpec.configuration
    RSpec.configuration = RSpec::Core::Configuration.new
    RSpec::Rails.add_rspec_rails_config_api_to(RSpec.configuration)
    yield
  ensure
    RSpec.configuration = original_config
  end

  RSpec.configure {|c| c.include self}
end
