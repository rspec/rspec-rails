require 'nokogiri'

rspec_rails_repo_path = File.expand_path('..', __dir__)
rspec_dependencies_gemfile = File.join(rspec_rails_repo_path, 'Gemfile-rspec-dependencies')
rails_dependencies_gemfile = File.join(rspec_rails_repo_path, 'Gemfile-rails-dependencies')
bundle_install_path = File.join(rspec_rails_repo_path, '..', 'bundle')
maintenance_branch_file = File.join(rspec_rails_repo_path, 'maintenance-branch')
ci_retry_script = File.join(
  rspec_rails_repo_path,
  'example_app_generator',
  'ci_retry_bundle_install.sh'
)
function_script_file = File.join(rspec_rails_repo_path, 'script/functions.sh')
capybara_backport_path = File.join(rspec_rails_repo_path, 'example_app_generator/spec/support/capybara.rb')

in_root do
  prepend_to_file "Rakefile", "require 'active_support/all'"

  # Remove the existing rails version so we can properly use main or other
  # edge branches
  gsub_file 'Gemfile', /^.*\bgem ['"]rails.*$/, ''
  gsub_file 'Gemfile', /^.*\bgem ['"]selenium-webdriver.*$/, ''
  gsub_file "Gemfile", /.*web-console.*/, ''
  gsub_file "Gemfile", /.*debug.*/, ''
  gsub_file "Gemfile", /.*puma.*/, ''
  gsub_file "Gemfile", /.*bootsnap.*/, ''

  append_to_file 'Gemfile', "gem 'rails-controller-testing'\n"

  gsub_file "Gemfile", /.*rails-controller-testing.*/, "gem 'rails-controller-testing', git: 'https://github.com/rails/rails-controller-testing'"

  # sqlite3 is an optional, unspecified, dependency of which Rails 6.0 only supports `~> 1.4`, Ruby 2.7 only supports < 1.7 and Rails 8.0 only supports `~> 2.0`
  if RUBY_VERSION.to_f < 3
    gsub_file "Gemfile", /.*gem..sqlite3.*/, "gem 'sqlite3', '~> 1.4', '< 1.7'"
  elsif Rails::VERSION::STRING > '8'
    gsub_file "Gemfile", /.*gem..sqlite3.*/, "gem 'sqlite3', '~> 2.0'"
  else
    gsub_file "Gemfile", /.*gem..sqlite3.*/, "gem 'sqlite3', '~> 1.4'"
  end

  # remove webdrivers
  gsub_file "Gemfile", /gem ['"]webdrivers['"]/, ""

  if RUBY_ENGINE == "jruby"
    gsub_file "Gemfile", /.*jdbc.*/, ''
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

  copy_file ci_retry_script, 'ci_retry_bundle_install.sh'
  gsub_file 'ci_retry_bundle_install.sh',
            'FUNCTIONS_SCRIPT_FILE',
            function_script_file
  gsub_file 'ci_retry_bundle_install.sh',
            'REPLACE_BUNDLE_PATH',
            bundle_install_path
  chmod 'ci_retry_bundle_install.sh', 0755

  copy_file capybara_backport_path, 'spec/support/capybara.rb'

  if Rails::VERSION::STRING > '7' && Rails::VERSION::STRING < '7.2'
    create_file 'app/assets/config/manifest.js' do
      "//= link application.css"
    end
    create_file 'app/assets/stylesheets/application.css'
  end
end
