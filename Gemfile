source "https://rubygems.org"
version_file = File.expand_path("../.rails-version", __FILE__)
RAILS_VERSION = ENV['RAILS_VERSION'] || (File.exist?(version_file) && File.read(version_file).chomp)

gemspec

rspec_dependencies_gemfile = File.expand_path("../Gemfile-rspec-dependencies", __FILE__)
eval_gemfile rspec_dependencies_gemfile

gem 'yard', '~> 0.8.7', :require => false

### deps for rdoc.info
group :documentation do
  gem 'redcarpet',     '2.3.0'
  gem 'github-markup', '1.0.0'
  if RUBY_VERSION > '2.0.0'
    gem 'relish'
  end
end

platforms :jruby do
  gem "jruby-openssl"
end

gem 'sqlite3', '~> 1.3.6'

# Version 6.0.4 of rdoc requires Ruby 2.2
if RUBY_VERSION < '2.2'
  gem 'rdoc', '< 6.0.4'
end

if RUBY_VERSION >= '2.4.0'
  gem 'json', '>= 2.0.2'
end

if RUBY_VERSION < '1.9'
  gem 'ffi', '< 1.9.19' # ffi dropped Ruby 1.8 support in 1.9.19
end
if RUBY_VERSION >= '2.0.0'
  gem 'rake', '>= 10.0.0'
elsif RUBY_VERSION >= '1.9.3'
  gem 'rake', '< 12.0.0' # rake 12 requires Ruby 2.0.0 or later
else
  gem 'rake', '< 11.0.0' # rake 11 requires Ruby 1.9.3 or later
end

# Version 3 of mime-types 3 requires Ruby 2.0
if RUBY_VERSION < '2.0.0'
  gem 'mime-types', '< 3'
end

# Capybara versions that support RSpec 3 only support RUBY_VERSION >= 1.9.3
if RUBY_VERSION >= '1.9.3'
  if /5(\.|-)[1-9]\d*/ === RAILS_VERSION || "master" == RAILS_VERSION
    gem 'capybara', '~> 2.13', :require => false
  else
    gem 'capybara', '~> 2.2.0', :require => false
  end
end

# Rack::Cache 1.3.0 requires Ruby >= 2.0.0
gem 'rack-cache', '< 1.3.0' if RUBY_VERSION < '2.0.0'

if RUBY_VERSION < '1.9.2'
  gem 'nokogiri', '~> 1.5.0'
elsif RUBY_VERSION < '1.9.3'
  gem 'nokogiri', '1.5.2'
else
  gem 'nokogiri', '1.6.7.1'
end

if RUBY_VERSION <= '1.8.7'
  # cucumber and gherkin require rubyzip as a runtime dependency on 1.8.7
  # Only < 1.0 supports 1.8.7
  gem 'rubyzip', '< 1.0'
end

if RUBY_VERSION >= '2.0.0' && RUBY_VERSION < '2.2.0'
  # our current rubocop version doesn't support the json version required by Ruby 2.4
  # our rails rubocop setup only supports 2.0 and 2.1
  gem 'rubocop', "~> 0.23.0"
end

custom_gemfile = File.expand_path("../Gemfile-custom", __FILE__)
eval_gemfile custom_gemfile if File.exist?(custom_gemfile)

rails_dependencies_gemfile = File.expand_path("../Gemfile-rails-dependencies", __FILE__)
eval_gemfile rails_dependencies_gemfile
