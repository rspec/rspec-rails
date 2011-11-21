require "bundler"
begin
  Bundler.setup
  Bundler::GemHelper.install_tasks
rescue
  raise "You need to install a bundle first. Try 'thor gemfile:use 3.1.0'"
end

task :build => :raise_if_psych_is_defined

task :raise_if_psych_is_defined do
  if defined?(Psych)
    raise <<-MSG
===============================================================================
Gems compiled in Ruby environments with Psych loaded are incompatible with Ruby
environments that don't have Psych loaded. Try building this gem in Ruby 1.8.7
instead.
===============================================================================
MSG
  end
end

require 'yaml'
require 'rspec'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

Cucumber::Rake::Task.new(:cucumber)

if RUBY_VERSION.to_f == 1.8
  namespace :rcov do
    task :clean do
      rm_rf 'coverage.data'
    end

    desc "Run cucumber features using rcov"
    Cucumber::Rake::Task.new :cucumber do |t|
      t.cucumber_opts = %w{--format progress}
      t.rcov = true
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
      t.rcov_opts << %[--text-report --sort coverage --aggregate coverage.data]
    end

    desc "Run all examples using rcov"
    RSpec::Core::RakeTask.new :spec do |t|
      t.rcov = true
      t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,features"]
      t.rcov_opts << %[--text-report --sort coverage --no-html --aggregate coverage.data]
    end
  end

  task :rcov => ["rcov:clean", "rcov:spec", "rcov:cucumber"]
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app do |t|
    unless File.directory?('./tmp/example_app')
      sh "rails new ./tmp/example_app --skip-javascript --skip-gemfile --skip-git"
      bindir = File.expand_path("bin")
      if test ?d, bindir
        Dir.chdir("./tmp/example_app") do
          sh "rm -rf test"
          sh "ln -s #{bindir}"
          application_file = File.read("config/application.rb")
          sh "rm config/application.rb"
          File.open("config/application.rb","w") do |f|
            f.write application_file.gsub("config.assets.enabled = true","config.assets.enabled = false")
          end
        end
      end
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    in_example_app "bin/rake rails:template LOCATION='../../templates/generate_stuff.rb'"
  end
end

def in_example_app(command)
  Dir.chdir("./tmp/example_app/") do
    Bundler.with_clean_env do
      sh command
    end
  end
end

namespace :db do
  task :migrate do
    in_example_app "bin/rake db:migrate"
  end

  namespace :test do
    task :prepare do
      in_example_app "bin/rake db:test:prepare"
    end
  end
end

desc "run a variety of specs against the generated app"
task :smoke do
  in_example_app "bin/rake rails:template --trace LOCATION='../../templates/run_specs.rb'"
end

desc 'clobber generated files'
task :clobber do
  rm_rf "pkg"
  rm_rf "tmp"
  rm_rf "doc"
  rm_rf ".yardoc"
  rm    "Gemfile.lock" if File.exist?("Gemfile.lock")
end

namespace :clobber do
  desc "clobber the generated app"
  task :app do
    rm_rf "tmp/example_app"
  end
end

desc "Push docs/cukes to relishapp using the relish-client-gem"
task :relish, :version do |t, args|
  raise "rake relish[VERSION]" unless args[:version]
  sh "cp Changelog.md features/Changelog.md"
  sh "relish push rspec/rspec-rails:#{args[:version]}"
  sh "rm features/Changelog.md"
end

task :default => [:spec, "clobber:app", "generate:app", "generate:stuff", :smoke, :cucumber]
