$LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
require 'rspec/rails/version'
# This needs to be installed on the system, as well as all of its rspec-2 deps
# - would be nicer if we could source them from the <repo>/pkg dirs
gem 'rspec-rails', :path => File.expand_path('../../../', __FILE__)

generate('rspec:install')

