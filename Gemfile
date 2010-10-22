source "http://rubygems.org"

%w[arel rails].each do |lib|
  gem lib, :path => File.expand_path("../vendor/#{lib}", __FILE__)
end

%w[rspec-rails rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end

gem "cucumber", "0.8.5"
gem "aruba", "0.2.2"
gem 'webrat', "0.7.2"
gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'autotest'

case RUBY_VERSION
when /^1\.9/
  gem 'ruby-debug19'
when /^1\.8/
  gem 'ruby-debug'
end
