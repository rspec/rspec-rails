source "http://rubygems.org"

gemspec

%w[rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  elsif ENV["CI"] || ENV["USE_GIT_REPOS"]
    gem lib, :git => "git://github.com/rspec/#{lib}.git"
  else
    gem lib
  end
end

### deps for rdoc.info
gem 'yard',          '0.8.0', :require => false
gem 'redcarpet',     '2.1.1'
gem 'github-markup', '0.7.2'

platforms :jruby do
  gem "jruby-openssl"
end

gem 'sqlite3', '~> 1.3.6'

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')

case version = ENV['RAILS_VERSION'] || File.read(File.expand_path("../.rails-version", __FILE__)).chomp
when /master/
  gem "rails", :git => "git://github.com/rails/rails.git"
  gem "arel", :git => "git://github.com/rails/arel.git"
  gem "journey", :git => "git://github.com/rails/journey.git"
  gem "active_record_deprecated_finders", :git => "git://github.com/rails/active_record_deprecated_finders.git"
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
