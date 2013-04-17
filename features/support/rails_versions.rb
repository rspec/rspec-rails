Around "@unsupported-on-rails-3-0" do |scenario, block|
  require 'rails'
  block.call unless ::Rails.version.to_s.start_with?("3.0")
end
