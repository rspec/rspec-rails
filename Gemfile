source "https://rubygems.org"

gemspec

eval_gemfile 'Gemfile-rspec-dependencies'

gem 'yard', '~> 0.9.24', require: false

group :documentation do
  gem 'github-markup', '~> 3.0.3'
  gem 'redcarpet', '~> 3.5.1', platforms: [:ruby]
end

gem 'capybara'
gem 'ffi', '> 1.15.5'
gem 'rake', '> 12'
gem 'rubocop', '~> 1.28.2'

if RUBY_VERSION.to_f > 3.3
  gem 'cucumber', git: 'https://github.com/cucumber/cucumber-ruby', branch: 'main'
end

custom_gemfile = File.expand_path('Gemfile-custom', __dir__)
eval_gemfile custom_gemfile if File.exist?(custom_gemfile)

eval_gemfile 'Gemfile-rails-dependencies'
