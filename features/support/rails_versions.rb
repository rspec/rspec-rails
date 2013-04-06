Around "@unsupported-on-rails-3-0" do |scenario, block|
  require 'rails'
  scenario.skip_invoke! if ::Rails.version.to_s.start_with?("3.0")
end
