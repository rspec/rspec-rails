rspec_rails_repo_path = File.expand_path("../../", __FILE__)
rspec_dependencies_gemfile = File.join(rspec_rails_repo_path, 'Gemfile-rspec-dependencies')
in_root do
  append_to_file 'Gemfile', <<-EOT.gsub(/^ +\|/, '')
    |gem 'rspec-rails',
    |    :path => '#{rspec_rails_repo_path}',
    |    :groups => [:development, :test]
    |eval_gemfile '#{rspec_dependencies_gemfile}'
  EOT
end
