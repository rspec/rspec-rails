$LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
require 'rspec/rails/version'
# This needs to be installed on the system, as well as all of its rspec-2 deps
# - would be nicer if we could source them from the <repo>/pkg dirs
gem 'rspec-rails', :version => "'#{Rspec::Rails::Version::STRING}'"

run('bundle install')

run('script/rails g rspec:install')
# run('script/rails g model thing name:string')
run('script/rails g scaffold wombats name:string')
# run('script/rails g controller widgets index')
# run('script/rails g integration_test widgets')

run('rake db:migrate')
run('rake db:test:prepare')
run('rspec spec')
run('rake spec')
