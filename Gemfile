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

platforms :jruby do
  gem "jruby-openssl"
end

gem 'sqlite3', '~> 1.3.6'
gem 'rake',    '~> 0.9.2'
gem 'rdoc'

group :development, :test do
  gem 'cucumber', '1.1.9'
  gem 'aruba',    '0.4.11'
  gem 'ZenTest',  '4.6.2'
  gem 'ammeter',  '0.2.4'
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')

case version = ENV['RAILS_VERSION'] || File.read(File.expand_path("../.rails-version", __FILE__)).chomp
when /master/
  gem "rails", :git => "git://github.com/rails/rails.git"
  gem "arel", :git => "git://github.com/rails/arel.git"
  gem "journey", :git => "git://github.com/rails/journey.git"
when /3-0-stable/
  gem "rails", :git => "git://github.com/rails/rails.git", :branch => "3-0-stable"
  gem "arel",  :git => "git://github.com/rails/arel.git", :branch => "2-0-stable"
when /3-1-stable/
  gem "rails", :git => "git://github.com/rails/rails.git", :branch => "3-1-stable"
when /3-2-stable/
  gem "rails", :git => "git://github.com/rails/rails.git", :branch => "3-2-stable"
  gem "journey", :git => "git://github.com/rails/journey.git"
else
  gem "rails", version
end
