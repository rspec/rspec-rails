require 'nokogiri'

rspec_rails_repo_path = File.expand_path('..', __dir__)
rspec_dependencies_gemfile = File.join(rspec_rails_repo_path, 'Gemfile-rspec-dependencies')
rails_dependencies_gemfile = File.join(rspec_rails_repo_path, 'Gemfile-rails-dependencies')
bundle_install_path = File.join(rspec_rails_repo_path, '..', 'bundle')
maintenance_branch_file = File.join(rspec_rails_repo_path, 'maintenance-branch')
travis_retry_script = File.join(
  rspec_rails_repo_path,
  'example_app_generator',
  'travis_retry_bundle_install.sh'
)
function_script_file = File.join(rspec_rails_repo_path, 'script/functions.sh')
sqlite_initializer = File.join(rspec_rails_repo_path, "example_app_generator/config/initializers/sqlite3_fix.rb")

in_root do
  prepend_to_file "Rakefile", "require 'active_support/all'"

  # Remove the existing rails version so we can properly use master or other
  # edge branches
  gsub_file 'Gemfile', /^.*\bgem 'rails.*$/, ''
  gsub_file "Gemfile", /.*web-console.*/, ''
  gsub_file "Gemfile", /.*debugger.*/, ''
  gsub_file "Gemfile", /.*byebug.*/, "gem 'byebug', '~> 9.0.6'"
  gsub_file "Gemfile", /.*puma.*/, ""
  gsub_file "Gemfile", /.*gem..sqlite3.*/, "gem 'sqlite3', '~> 1.3.6'"
  gsub_file "Gemfile", /.*bootsnap.*/, ""

  if Rails::VERSION::STRING >= '5.0.0'
    append_to_file('Gemfile', "gem 'rails-controller-testing'\n")
  end

  if Rails::VERSION::STRING >= '6'
    gsub_file "Gemfile", /.*gem..sqlite3.*/, "gem 'sqlite3', '~> 1.4'"
    gsub_file "Gemfile", /.*rails-controller-testing.*/, "gem 'rails-controller-testing', git: 'https://github.com/rails/rails-controller-testing'"
  end

  if Rails::VERSION::STRING >= "5.1.0"
    if RUBY_VERSION < "2.3"
      gsub_file "Gemfile", /.*capybara.*/, "gem 'capybara', '~> 3.1.0'"
    elsif RUBY_VERSION < "2.4"
      gsub_file "Gemfile", /.*capybara.*/, "gem 'capybara', '~> 3.15.0'"
    end
    if Rails::VERSION::STRING >= "5.2.0"
      gsub_file "Gemfile", /.*chromedriver-helper.*/, "gem 'webdrivers', '< 4.0.0'"
    else
      gsub_file "Gemfile", /.*chromedriver-helper.*/, "gem 'webdrivers'"
    end
  end

  if Rails::VERSION::STRING >= '5.2.0' && Rails::VERSION::STRING < '6'
    copy_file sqlite_initializer, 'config/initializers/sqlite3_fix.rb'
  end

  # Nokogiri version is pinned in rspec-rails' Gemfile since it tend to cause installation problems
  # on Travis CI, so we pin nokogiri in this example app also.
  if RUBY_ENGINE != "jruby"
    append_to_file 'Gemfile', "gem 'nokogiri', '#{Nokogiri::VERSION}'\n"
  else
    gsub_file "Gemfile", /.*jdbc.*/, ""
  end

  # Use our version of RSpec and Rails
  append_to_file 'Gemfile', <<-EOT.gsub(/^ +\|/, '')
    |gem 'rake', '>= 10.0.0'
    |
    |gem 'rspec-rails',
    |    :path => '#{rspec_rails_repo_path}',
    |    :groups => [:development, :test]
    |eval_gemfile '#{rspec_dependencies_gemfile}'
    |eval_gemfile '#{rails_dependencies_gemfile}'
  EOT

  copy_file maintenance_branch_file, 'maintenance-branch'

  copy_file travis_retry_script, 'travis_retry_bundle_install.sh'
  gsub_file 'travis_retry_bundle_install.sh',
            'FUNCTIONS_SCRIPT_FILE',
            function_script_file
  gsub_file 'travis_retry_bundle_install.sh',
            'REPLACE_BUNDLE_PATH',
            bundle_install_path
  chmod 'travis_retry_bundle_install.sh', 0755
end
