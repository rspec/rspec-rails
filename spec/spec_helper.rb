require 'bundler'
Bundler.setup

require 'rspec/rails'

def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

Rspec.configure do |c|
  c.color_enabled = !in_editor?
end

