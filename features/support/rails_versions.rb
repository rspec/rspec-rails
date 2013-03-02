Around "@unsupported-on-rails-3-0" do |scenario, block|
  require 'rails'
  scenario.skip_invoke! if Rails.version >= '3.0.0' && Rails.version < '3.1.0'
end
