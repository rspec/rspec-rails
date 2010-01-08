desc 'checkout rails'
task :get_rails do
  if File.directory?('./rails')
    sh "cd rails && git pull"
  else
    sh "git clone git://github.com/rails/rails --depth 0"
  end

end

desc 'create app'
task :create_app do
  rm_rf "example_app"
  ruby "rails/railties/bin/rails example_app --dev -m example_app_template.rb"
end

