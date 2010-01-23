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
                         :integration_tool => false,
                         :routes => true,
                         :views => false
   
      g.integration_tool :rspec
    end
  end
end
CODE

run('gem bundle')

generate('rspec:install')
generate('model', 'thing', 'name:string')
generate('controller', 'widgets', 'index', 'new')

run('rake db:migrate')
run('rake db:test:prepare')
run('rspec spec')
run('rake spec')
