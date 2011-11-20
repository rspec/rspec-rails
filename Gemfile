source "http://rubygems.org"

%w[rspec rspec-core rspec-expectations rspec-mocks rspec-rails].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  elsif ENV["CI"] || ENV["USE_GIT_REPOS"]
    gem lib, :git => "git://github.com/rspec/#{lib}.git"
  else
    gem lib
  end
end

gem 'rake', '0.9.2'
gem 'rdoc'
gem 'sqlite3-ruby', :require => 'sqlite3'
gem "cucumber", "1.0.0"
gem "aruba", "0.4.2"
gem "ZenTest", "~> 4.4.2"
gem 'ammeter', '~> 0.1'

platforms :jruby do
  gem "jruby-openssl"
end

# gem "webrat", "0.7.3"
# gem "capybara", "~> 0.4"
# gem "capybara", "1.0.0.beta1"

group :development do
  gem 'gherkin', '2.4.5'
  gem "rcov", "0.9.9"
  gem "relish", "~> 0.5.0"
  gem "guard-rspec", "0.1.9"

  if RUBY_PLATFORM =~ /darwin/
    gem "growl", "1.0.3"
    gem "autotest-fsevent", "~> 0.2.4"
    gem "autotest-growl", "~> 0.2.9"
  end

  platforms :mri_18 do
    gem 'ruby-debug'
  end

  platforms :mri_19 do
    if RUBY_VERSION == '1.9.2'
      gem 'linecache19', '~> 0.5.12'
      gem 'ruby-debug19', '~> 0.11.6'
      gem 'ruby-debug-base19', '~> 0.11.25'
    end
  end

  platforms :ruby_18, :ruby_19 do
    gem "rb-fsevent", "~> 0.3.9"
    gem "ruby-prof", "~> 0.9.2"
  end
end

case version = File.read(".rails-version").chomp
when /master/
  gem "rails", :git => "git://github.com/rails/rails.git"
  gem "journey", :git => "git://github.com/rails/journey.git"
when /3-0-stable/
  gem "rails", :git => "git://github.com/rails/rails.git", :branch => "3-0-stable"
  gem "arel",  :git => "git://github.com/rails/arel.git", :branch => "2-0-stable"
when /3-1-stable/
  gem "rails", :git => "git://github.com/rails/rails.git", :branch => "3-1-stable"
else
  gem "rails", version
end
