require 'rubygems'
gem 'jeweler', '>= 1.4.0'
require 'rake'
require 'yaml'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'lib'))

require 'rake/rdoctask'
require 'rspec/rails/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-rails"
    gem.version = Rspec::Rails::Version::STRING
    gem.summary = "Rspec-2 for Rails-3"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/rspec-rails"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.add_dependency "rspec", ">= 2.0.0.a6"
    gem.add_dependency "webrat", ">= 0.7.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


desc 'create app, generate a bunch of stuff, and run rake spec'
task :create_app do |t|
  if File.directory?('./tmp/rails')
    rm_rf "tmp/example_app"
    ruby "./tmp/rails/railties/bin/rails tmp/example_app --dev -m example_app_template.rb"
  else
    puts <<-MESSAGE

You need to install rails in ./tmp/rails before you can run the 
#{t.name} task:
  
  git clone git://github.com/rails/rails tmp/rails

(We'll automate this eventually, but running 'git clone' from rake in this
project is mysteriously full of fail)

MESSAGE
  end
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
end

task :default => :create_app

