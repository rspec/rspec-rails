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

# Capybara versions that support RSpec 3 only support RUBY_VERSION >= 1.9.3
if RUBY_VERSION >= '1.9.3'
  if /5(\.|-)[1-9]\d*/ === RAILS_VERSION || "master" == RAILS_VERSION
    gem 'capybara', '~> 2.13', :require => false
  else
    gem 'capybara', '~> 2.2.0', :require => false
  end
end

# Nokogiri is required by Capybara, but we require Capybara only on Ruby 1.9.3+,
# so we need to explicitly specify Nokogiri dependency on Ruby 1.9.2 to run cukes
gem 'nokogiri' if RUBY_VERSION == '1.9.2'

# Minitest version 5.12.0 rely on Ruby 2.4 features and doesn't specify a Ruby version constraint
gem 'minitest', '!= 5.12.0'

gem 'rake'

if RUBY_VERSION >= '2.0.0' && RUBY_VERSION < '2.2.0'
  # our current rubocop version doesn't support the json version required by Ruby 2.4
  # our rails rubocop setup only supports 2.0 and 2.1
  gem 'rubocop', "~> 0.23.0"
end

custom_gemfile = File.expand_path("../Gemfile-custom", __FILE__)
eval_gemfile custom_gemfile if File.exist?(custom_gemfile)

rails_dependencies_gemfile = File.expand_path("../Gemfile-rails-dependencies", __FILE__)
eval_gemfile rails_dependencies_gemfile
