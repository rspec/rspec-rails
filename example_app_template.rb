$LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
require 'rspec/rails/version'
# This needs to be installed on the system, as well as all of its rspec-2 deps
# - would be nicer if we could source them from the <repo>/pkg dirs
gem 'rspec-rails', :path => File.expand_path('../../../', __FILE__)

run('bundle install')

run('script/rails g rspec:install')
run('script/rails g controller wombats index')
run('script/rails g integration_test widgets')
run('script/rails g mailer Notifications signup')
run('script/rails g model thing name:string')
run('script/rails g observer widget')
run('script/rails g scaffold widgets name:string')

run('rake db:migrate')
run('rake db:test:prepare')
run('rspec spec -cfdoc')
run('rake spec')
run('rake spec:requests')
run('rake spec:models')
run('rake spec:views')
run('rake spec:controllers')
run('rake spec:helpers')
run('rake spec:mailers')
run('rake stats')
