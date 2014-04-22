module Helpers
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
