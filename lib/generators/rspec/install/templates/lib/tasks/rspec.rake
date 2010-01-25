begin
  require 'rspec/core'
  require 'rspec/core/rake_task'
rescue MissingSourceFile 
  module Rspec
    module Core
      class RakeTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

            # ... otherwise, do this:
            raise <<-MSG

#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
#{"*" * 80}
MSG
          end
        end
      end
    end
  end
end

Rake.application.instance_variable_get('@tasks').delete('default')

spec_prereq = File.exist?(File.join(Rails.root, 'config', 'database.yml')) ? "db:test:prepare" : :noop
task :noop do
end

task :default => :spec
task :stats => "spec:statsetup"

desc "Run all specs in spec directory (excluding plugin specs)"
Rspec::Core::RakeTask.new(:spec => spec_prereq)

# namespace :spec do
  # desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  # Rspec::Core::RakeTask.new(:rcov) do |t|
    # t.spec_opts = ['--options', "\"#{Rails.root}/spec/spec.opts\""]
    # t.spec_files = FileList['spec/**/*_spec.rb']
    # t.rcov = true
    # t.rcov_opts = lambda do
      # IO.readlines("#{Rails.root}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    # end
  # end

  # desc "Print Rspecdoc for all specs (excluding plugin specs)"
  # Rspec::Core::RakeTask.new(:doc) do |t|
    # t.spec_opts = ["--format", "specdoc", "--dry-run"]
    # t.spec_files = FileList['spec/**/*_spec.rb']
  # end

  # desc "Print Rspecdoc for all plugin examples"
  # Rspec::Core::RakeTask.new(:plugin_doc) do |t|
    # t.spec_opts = ["--format", "specdoc", "--dry-run"]
    # t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*')
  # end

  # [:models, :controllers, :views, :helpers, :lib, :integration].each do |sub|
    # desc "Run the code examples in spec/#{sub}"
    # Rspec::Core::RakeTask.new(sub => spec_prereq) do |t|
      # t.spec_opts = ['--options', "\"#{Rails.root}/spec/spec.opts\""]
      # t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
    # end
  # end

  # desc "Run the code examples in vendor/plugins (except RRspec's own)"
  # Rspec::Core::RakeTask.new(:plugins => spec_prereq) do |t|
    # t.spec_opts = ['--options', "\"#{Rails.root}/spec/spec.opts\""]
    # t.spec_files = FileList['vendor/plugins/**/spec/**/*_spec.rb'].exclude('vendor/plugins/rspec/*').exclude("vendor/plugins/rspec-rails/*")
  # end

  # namespace :plugins do
    # desc "Runs the examples for rspec_on_rails"
    # Rspec::Core::RakeTask.new(:rspec_on_rails) do |t|
      # t.spec_opts = ['--options', "\"#{Rails.root}/spec/spec.opts\""]
      # t.spec_files = FileList['vendor/plugins/rspec-rails/spec/**/*_spec.rb']
    # end
  # end

  # task :statsetup do
    # require 'code_statistics'
    # ::STATS_DIRECTORIES << %w(Model\ specs spec/models) if File.exist?('spec/models')
    # ::STATS_DIRECTORIES << %w(View\ specs spec/views) if File.exist?('spec/views')
    # ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers) if File.exist?('spec/controllers')
    # ::STATS_DIRECTORIES << %w(Helper\ specs spec/helpers) if File.exist?('spec/helpers')
    # ::STATS_DIRECTORIES << %w(Library\ specs spec/lib) if File.exist?('spec/lib')
    # ::STATS_DIRECTORIES << %w(Routing\ specs spec/routing) if File.exist?('spec/routing')
    # ::STATS_DIRECTORIES << %w(Integration\ specs spec/integration) if File.exist?('spec/integration')
    # ::CodeStatistics::TEST_TYPES << "Model specs" if File.exist?('spec/models')
    # ::CodeStatistics::TEST_TYPES << "View specs" if File.exist?('spec/views')
    # ::CodeStatistics::TEST_TYPES << "Controller specs" if File.exist?('spec/controllers')
    # ::CodeStatistics::TEST_TYPES << "Helper specs" if File.exist?('spec/helpers')
    # ::CodeStatistics::TEST_TYPES << "Library specs" if File.exist?('spec/lib')
    # ::CodeStatistics::TEST_TYPES << "Routing specs" if File.exist?('spec/routing')
    # ::CodeStatistics::TEST_TYPES << "Integration specs" if File.exist?('spec/integration')
  # end

  # namespace :db do
    # namespace :fixtures do
      # desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y. Load from subdirectory in test/fixtures using FIXTURES_DIR=z."
      # task :load => :environment do
        # ActiveRecord::Base.establish_connection(Rails.env)
        # base_dir = File.join(Rails.root, 'spec', 'fixtures')
        # fixtures_dir = ENV['FIXTURES_DIR'] ? File.join(base_dir, ENV['FIXTURES_DIR']) : base_dir

        # require 'active_record/fixtures'
        # (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/).map {|f| File.join(fixtures_dir, f) } : Dir.glob(File.join(fixtures_dir, '*.{yml,csv}'))).each do |fixture_file|
          # Fixtures.create_fixtures(File.dirname(fixture_file), File.basename(fixture_file, '.*'))
        # end
      # end
    # end
  # end
# end
