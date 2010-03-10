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
    gem.summary = "rspec-rails-#{Rspec::Rails::Version::STRING}"
    gem.description = "Rspec-2 for Rails-3"
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

  This is beta software. If you are looking
  for a supported production release, please
  "gem install rspec-rails" (without --pre).

#{"*"*50}
EOM
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

namespace :gem do
  desc "push to gemcutter"
  task :push => :build do
    system "gem push pkg/rspec-rails-#{Rspec::Rails::Version::STRING}.gem"
  end
end

namespace :rails do
  desc "clone the rails repo"
  task :clone do
    mkdir 'tmp' unless File.directory?('tmp')
    unless File.directory?('tmp/rails')
      Dir.chdir('tmp') do
        sh "git clone git://github.com/rails/rails"
      end
    end
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app => ["rails:clone", :clobber_app] do |t|
    ruby "./tmp/rails/railties/bin/rails tmp/example_app --dev -m example_app_template.rb"
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    Dir.chdir("./tmp/example_app/") do
      sh "rake rails:template LOCATION='../../templates/generate_stuff.rb'"
    end
  end
end

desc "run a variety of specs against the generated app"
task :run_specs do
  Dir.chdir("./tmp/example_app/") do
    sh "rake rails:template LOCATION='../../templates/run_specs.rb'"
  end
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
end

task :clobber_app do
  rm_rf "tmp/example_app"
end

task :default => ["generate:app", "generate:stuff", :run_specs]

