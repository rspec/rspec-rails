desc 'checkout rails'
task :get_rails do
  if File.directory?('./tmp/rails')
    sh "cd ./tmp/rails && git pull"
  else
    mkdir_p "tmp"
    sh "cd ./tmp && git clone git://github.com/rails/rails --depth 0"
  end
end

desc 'create app'
task :create_app do
  rm_rf "example_app"
  ruby "tmp/rails/railties/bin/rails tmp/example_app --dev -m example_app_template.rb"
end

