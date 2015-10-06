rspec_rails_repo_path = File.expand_path("../../", __FILE__)
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

in_root do
  # Remove the existing rails version so we can properly use master or other
  # edge branches
  gsub_file 'Gemfile', /^.*\bgem 'rails.*$/, ''

  # Use our version of RSpec and Rails
  append_to_file 'Gemfile', <<-EOT.gsub(/^ +\|/, '')
    |# Rack::Cache 1.3.0 requires Ruby >= 2.0.0
    |gem 'rack-cache', '< 1.3.0' if RUBY_VERSION < '2.0.0'
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
