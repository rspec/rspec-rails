Around "@unsupported-on-rails-3-0" do |scenario, block|
  require 'rails'
  scenario.skip_invoke! if RSpec::Rails::Version.rails_version?('~>3.0.0')
end
