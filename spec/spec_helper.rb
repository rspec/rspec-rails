%w(actionmailer actionpack activemodel activerecord activeresource activesupport railties).each do |directory|
  $LOAD_PATH.unshift File.expand_path( File.join(File.dirname(__FILE__), "..", "tmp", "rails", directory, "lib") )
end

require 'i18n'
require 'rack'
require 'rack/mock'
require 'rack/mime'
require 'active_support'
require 'active_support/core_ext'
require 'action_dispatch'
require 'action_controller'
require 'active_record'
require 'rspec/rails'
