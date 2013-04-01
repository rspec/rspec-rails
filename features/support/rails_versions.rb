Around "@unsupported-on-rails-3-0" do |scenario, block|
  require 'rails'
  scenario.skip_invoke! if Gem::Requirement.new('~>3.0.0').satisfied_by?(Gem::Version.new(::Rails.version.to_s))
end
