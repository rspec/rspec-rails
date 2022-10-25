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

  # sqlite3 is an optional, unspecified, dependency and Rails 6.0 only supports `~> 1.4`
  gsub_file "Gemfile", /.*gem..sqlite3.*/, "gem 'sqlite3', '~> 1.4'"

  gsub_file "Gemfile", /.*chromedriver-helper.*/, "gem 'webdrivers'"

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

  if Rails::VERSION::STRING > '7'
    create_file 'app/assets/config/manifest.js' do
      "//= link application.css"
    end
    create_file 'app/assets/stylesheets/application.css'
  end
end
