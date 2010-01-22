require 'rubygems'
require 'rake'
require 'yaml'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'lib'))

require 'rake/rdoctask'
require 'rspec/rails/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-rails"
    gem.summary = "RSpec for Rails"
    gem.description = 'RSpec Rails'
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/rspec-rails"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.version = Rspec::Rails::Version::STRING
    gem.add_dependency "rspec", ">= #{Rspec::Rails::Version::STRING}"
    gem.add_development_dependency('cucumber', '>= 0.5.3')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'checkout rails'
task :get_rails do
  if File.directory?('./rails')
    sh "cd ./rails && git pull"
  else
    sh "git clone git://github.com/rails/rails --depth 0"
  end
end

desc 'create app'
task :create_app => [:build] do
  rm_rf "tmp/example_app"
  ruby "rails/railties/bin/rails tmp/example_app --dev -m example_app_template.rb"
end

desc 'run controller generator'
task :generate_controller do
  sh "cd ./tmp/example_app && script/generate controller things new"
end

desc 'generate rspec'
task :generate_rspec do
  sh "cd ./rails && script/generate rspec"
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
end
