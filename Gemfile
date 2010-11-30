source "http://rubygems.org"

gem "rails", :path => File.expand_path("../vendor/rails", __FILE__)
gem "rack", :git => "git://github.com/rack/rack.git"

%w[rspec-rails rspec rspec-core rspec-expectations rspec-mocks].each do |lib|
  gem lib, :path => File.expand_path("../../#{lib}", __FILE__)
end

gem "cucumber", :git => "git://github.com/dchelimsky/cucumber", :branch => "update-gemspec"
gem "aruba", "0.2.2"
gem 'webrat', "0.7.2"
gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'relish'

gem 'autotest'

platforms :mri_19 do
  gem 'ruby-debug19'
end

platforms :mri_18 do
  gem 'ruby-debug'
end
