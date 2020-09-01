source "https://rubygems.org"
version_file = File.expand_path("../.rails-version", __FILE__)
RAILS_VERSION = ENV['RAILS_VERSION'] || (File.exist?(version_file) && File.read(version_file).chomp)

gemspec

rspec_dependencies_gemfile = File.expand_path("../Gemfile-rspec-dependencies", __FILE__)
eval_gemfile rspec_dependencies_gemfile

gem 'yard', '~> 0.9.24', :require => false

### deps for rdoc.info
group :documentation do
  if RUBY_VERSION > '2.0.0'
    gem 'redcarpet'
    gem 'github-markup'
    gem 'relish'
  end
end

platforms :jruby do
  gem "jruby-openssl"
end

gem 'sqlite3', '~> 1.3.6'

gem 'ffi'

gem 'capybara', :require => false

custom_gemfile = File.expand_path("../Gemfile-custom", __FILE__)
eval_gemfile custom_gemfile if File.exist?(custom_gemfile)

rails_dependencies_gemfile = File.expand_path("../Gemfile-rails-dependencies", __FILE__)
eval_gemfile rails_dependencies_gemfile
