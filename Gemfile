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

gem 'rake', '0.9.2'
gem 'rdoc'
gem 'sqlite3-ruby', :require => 'sqlite3'

group :development, :test do
  gem "cucumber", "1.0.0"
  gem "aruba", "0.4.2"
  gem "ZenTest", "~> 4.4.2"
end

group :test do
  gem 'ammeter', '~> 0.1'
end

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
    gem 'ruby-debug19', '~> 0.11.6'
    if RUBY_VERSION == '1.9.3' && !ENV['TRAVIS']
      if `gem list ruby-debug-base19` =~ /0\.11\.26/
        gem 'ruby-debug-base19', '0.11.26'
      else
        warn "Download and install ruby-debug-base19-0.11.26 from http://rubyforge.org/frs/shownotes.php?release_id=46303"
      end

      if `gem list linecache19` =~ /0\.5\.13/
        gem 'linecache19', '0.5.13'
      else
        warn "Download and install linecache19-0.5.13 from http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem"
      end
    else
      gem 'ruby-debug-base19', '~> 0.11.25'
      gem 'linecache19',       '~> 0.5.12'
    end
  end

  platforms :ruby_18, :ruby_19 do
    gem "rb-fsevent", "~> 0.3.9"
    gem "ruby-prof", "~> 0.9.2"
  end
end

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
else
  gem "rails", version
end
