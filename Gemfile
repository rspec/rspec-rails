source "https://rubygems.org"
version_file = File.expand_path('.rails-version', __dir__)
RAILS_VERSION = ENV['RAILS_VERSION'] || (File.exist?(version_file) && File.read(version_file).chomp) || ""

gemspec

eval_gemfile 'Gemfile-rspec-dependencies'

gem 'yard', '~> 0.9.24', require: false

group :documentation do
  gem 'github-markup', '~> 3.0.3'
  gem 'redcarpet', '~> 3.4.0', platforms: [:ruby]
  gem 'relish', '~> 0.7.1'
end

platforms :jruby do
  gem "jruby-openssl"
end

case RAILS_VERSION
when /main/
  MAJOR = 6
  MINOR = 0
when /5-2-stable/
  MAJOR = 5
  MINOR = 2
when /stable/
  MAJOR = 6
  MINOR = 0
when nil, false, ""
  MAJOR = 6
  MINOR = 0
else
  match = /(\d+)(\.|-)(\d+)/.match(RAILS_VERSION)
  MAJOR, MINOR = match.captures.map(&:to_i).compact
end

if MAJOR >= 6
  gem 'selenium-webdriver', '~> 3.5', require: false
  gem 'sqlite3', '~> 1.4', platforms: [:ruby]
else
  gem 'sqlite3', '~> 1.3.6', platforms: [:ruby]
end

gem 'ffi', '~> 1.9.25'

gem 'rake', '~> 12'

gem 'mime-types', "~> 3"

if RUBY_VERSION.to_f < 2.3
  gem 'capybara', '~> 3.1.0'
elsif RUBY_VERSION.to_f < 2.4
  gem 'capybara', '< 3.16'
elsif RUBY_VERSION.to_f < 2.5
  gem 'capybara', '< 3.33'
else
  gem 'capybara', '>= 2.13', '< 4.0', require: false
end

if MAJOR < 6
  gem 'nokogiri', '1.9.1'
else
  gem 'nokogiri', '>= 1.10.8'
end

gem "rubyzip", '~> 1.2'

if RUBY_VERSION.to_f >= 2.3
  gem 'rubocop', '~> 0.80.1'
end

custom_gemfile = File.expand_path('Gemfile-custom', __dir__)
eval_gemfile custom_gemfile if File.exist?(custom_gemfile)

eval_gemfile 'Gemfile-rails-dependencies'
