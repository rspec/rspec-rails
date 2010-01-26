$LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
require 'rspec/rails/version'
# This needs to be installed on the system, as well as all of its rspec-2 deps
# - would be nicer if we could source them from the <repo>/pkg dirs
gem 'rspec-rails', :version => "'#{Rspec::Rails::Version::STRING}'"

initializer 'generators.rb', <<-CODE
module ExampleApp
  class Application < Rails::Application
    config.generators do |g|
      g.test_framework   :rspec,
                         :fixtures => false,
                         :routes => false,
                         :views => false
    end
  end
end
CODE

run('gem bundle')

generate('rspec:install')
generate('model', 'thing', 'name:string')
generate('controller', 'widgets', 'index')
generate('integration_test', 'widgets')

run('rake db:migrate')
run('rake db:test:prepare')
run('script/rspec spec')
run('rake spec')
