source "https://rubygems.org"

gemspec

%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  elsif ENV["CI"] || ENV["USE_GIT_REPOS"]
    gem lib, :git => "git://github.com/rspec/#{lib}.git", :branch => '2-14-maintenance'
  else
    gem lib
  end
end

### deps for rdoc.info
group :documentation do
  gem 'yard',          '0.8.7.3', :require => false
  gem 'redcarpet',     '2.3.0'
  gem 'github-markup', '1.0.0'
end

platforms :jruby do
  gem "jruby-openssl"
end

gem 'sqlite3', '~> 1.3.6'

# Capybara 2.1 requires Ruby >= 1.9.3
if RUBY_VERSION < '1.9.3'
  gem 'capybara', '>= 2.0.0', '< 2.1.0'
end

if RUBY_VERSION < '1.9.2'
  gem 'nokogiri', '~> 1.5.0'
end

if RUBY_VERSION <= '1.8.7'
  # cucumber and gherkin require rubyzip as a runtime dependency on 1.8.7
  # Only < 1.0 supports 1.8.7
  gem 'rubyzip', '< 1.0'
end

custom_gemfile = File.expand_path("../Gemfile-custom", __FILE__)
eval File.read(custom_gemfile) if File.exist?(custom_gemfile)

version_file = File.expand_path("../.rails-version", __FILE__)
case version = ENV['RAILS_VERSION'] || (File.exist?(version_file) && File.read(version_file).chomp)
when /master/
  gem "rails", :git => "git://github.com/alindeman/rails.git", :branch => "issue_13390"
  gem "arel", :git => "git://github.com/rails/arel.git"
  gem "journey", :git => "git://github.com/rails/journey.git"
  gem "activerecord-deprecated_finders", :git => "git://github.com/rails/activerecord-deprecated_finders.git"
  gem "rails-observers", :git => "git://github.com/rails/rails-observers"
  gem 'sass-rails', :git => "git://github.com/rails/sass-rails.git"
  gem 'coffee-rails', :git => "git://github.com/rails/coffee-rails.git"
when /stable$/
  gem "rails", :git => "git://github.com/rails/rails.git", :branch => version
when nil, false, ""
  gem "rails", "~> 4.0.4"
else
  gem "rails", version
end
