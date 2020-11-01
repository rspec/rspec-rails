require 'active_support'
require 'active_support/core_ext/module'

using_source_path(File.expand_path(__dir__)) do
  # Comment out the default mailer stuff
  comment_lines 'config/environments/development.rb', /action_mailer/
  comment_lines 'config/environments/test.rb', /action_mailer/

  initializer 'action_mailer.rb', <<-CODE
  require "action_view/base"
    if ENV['DEFAULT_URL']
      ExampleApp::Application.configure do
        config.action_mailer.default_url_options = { :host => ENV['DEFAULT_URL'] }
      end
    end
  CODE

  copy_file 'spec/support/default_preview_path'
  chmod 'spec/support/default_preview_path', 0755
  if skip_active_record?
    comment_lines 'spec/support/default_preview_path', /active_record/
    comment_lines 'spec/support/default_preview_path', /active_storage/
  end
  copy_file 'spec/verify_mailer_preview_path_spec.rb'
end
