source "https://rubygems.org"
version_file = File.expand_path("../.rails-version", __FILE__)
RAILS_VERSION = ENV['RAILS_VERSION'] || (File.exist?(version_file) && File.read(version_file).chomp) || ""

gemspec

rspec_dependencies_gemfile = File.expand_path("../Gemfile-rspec-dependencies", __FILE__)
eval_gemfile rspec_dependencies_gemfile

gem 'yard', '~> 0.8.7', require: false

### deps for rdoc.info
group :documentation do
  gem 'github-markup', '~> 3.0.3'
  gem 'redcarpet', '~> 3.4.0', platforms: [:ruby]
  gem 'relish', '~> 0.7.1'
end

platforms :jruby do
  gem "jruby-openssl"
end

case RAILS_VERSION
when /master/
  MAJOR = 6
  MINOR = 0
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

gem 'capybara', '>= 2.13', '< 4.0', require: false

if MAJOR < 6
  gem 'nokogiri', '1.9.1'
else
  gem 'nokogiri', '>= 1.10.4'
end

gem "rubyzip", '~> 1.2'

gem 'rubocop', '~> 0.79.0'

custom_gemfile = File.expand_path("../Gemfile-custom", __FILE__)
eval_gemfile custom_gemfile if File.exist?(custom_gemfile)

rails_dependencies_gemfile = File.expand_path("../Gemfile-rails-dependencies", __FILE__)
eval_gemfile rails_dependencies_gemfile
