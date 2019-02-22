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
  gem 'relish'
end

platforms :jruby do
  gem "jruby-openssl"
end

gem 'sqlite3', '~> 1.3.6'

if RUBY_VERSION >= '2.4.0'
  gem 'json', '>= 2.0.2'
end

gem 'ffi', '~> 1.9.25'

gem 'rake', '>= 10.0.0'

gem 'mime-types', '< 3'

gem 'capybara', '~> 2.13', :require => false

gem 'nokogiri', '1.8.5'

gem "rubyzip", '>= 1.2.2'

gem 'rubocop'

custom_gemfile = File.expand_path("../Gemfile-custom", __FILE__)
eval_gemfile custom_gemfile if File.exist?(custom_gemfile)

rails_dependencies_gemfile = File.expand_path("../Gemfile-rails-dependencies", __FILE__)
eval_gemfile rails_dependencies_gemfile
