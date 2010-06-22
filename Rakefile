require "bundler"
Bundler.setup

require 'rake'
require 'yaml'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'rake/rdoctask'
require 'rspec/rails/version'
require 'rspec'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = %w{--format progress}
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspec-rails"
    gem.version = RSpec::Rails::Version::STRING
    gem.summary = "rspec-rails-#{RSpec::Rails::Version::STRING}"
    gem.description = "RSpec-2 for Rails-3"
    gem.email = "dchelimsky@gmail.com;chad.humphries@gmail.com"
    gem.homepage = "http://github.com/rspec/rspec-rails"
    gem.authors = ["David Chelimsky", "Chad Humphries"]
    gem.rubyforge_project = "rspec"
    gem.add_dependency "rspec", gem.version
    gem.add_dependency "webrat", ">= 0.7.0"
    gem.post_install_message = <<-EOM
#{"*"*50}

  Thank you for installing #{gem.summary}!

  This version of rspec-rails only works with 
  versions of rails >= 3.0.0.pre.

  Be sure to run the following command in each of your
  Rails apps if you're upgrading:

    script/rails generate rspec:install

#{"*"*50}
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :gem do
  desc "push to gemcutter"
  task :push => :build do
    system "gem push pkg/rspec-rails-#{RSpec::Rails::Version::STRING}.gem"
  end
end

namespace :rails do
  desc "clone the rails repo"
  task :clone do
    mkdir 'vendor' unless File.directory?('vendor')
    install_bundle = false
    unless File.directory?('vendor/arel')
      install_bundle = true
      Dir.chdir('vendor') do
        sh "git clone git://github.com/rails/arel"
      end
    end
    unless File.directory?('vendor/rails')
      install_bundle = true
      Dir.chdir('vendor') do
        sh "git clone git://github.com/rails/rails"
      end
    end
    sh "bundle install" if install_bundle
  end

  desc "update the rails repo"
  task :update => :clone do
    Dir.chdir('vendor/arel') do
      sh "git checkout master"
      sh "git pull"
    end
    Dir.chdir('vendor/rails') do
      sh "git checkout master"
      sh "git pull"
    end
    sh "bundle install"
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app => ["rails:clone"] do |t|
    unless File.directory?('./tmp/example_app')
      sh "bundle exec ./vendor/rails/bin/rails new ./tmp/example_app"
      sh "cp ./templates/Gemfile ./tmp/example_app/" 
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    Dir.chdir("./tmp/example_app/") do
      sh "rake rails:template LOCATION='../../templates/generate_stuff.rb'"
    end
  end
end

namespace :db do
  task :migrate do
    Dir.chdir("./tmp/example_app/") do
      sh "rake db:migrate"
    end
  end

  namespace :test do
    task :prepare do
      Dir.chdir("./tmp/example_app/") do
        sh "rake db:test:prepare"
      end
    end
  end
end

desc "run a variety of specs against the generated app"
task :smoke do
  Dir.chdir("./tmp/example_app/") do
    sh "rake rails:template LOCATION='../../templates/run_specs.rb'"
  end
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
  rm_rf "tmp"
  rm    "Gemfile.lock" if File.exist?("Gemfile.lock")
end

namespace :clobber do
  desc "clobber the generated app"
  task :app do
    rm_rf "tmp/example_app"
  end
end

task :default => ["clobber:app", "generate:app", "generate:stuff", :smoke, :spec, :cucumber]

