require 'active_support'
require 'active_support/core_ext/module'

# We need to copy this method from Thor for older Rails versions
def comment_lines(path, flag, *args)
  flag = flag.respond_to?(:source) ? flag.source : flag
  gsub_file(path, /^(\s*)([^#|\n]*#{flag})/, '\1# \2', *args)
end

using_source_path(File.expand_path('..', __FILE__)) do
  # Comment out the default mailer stuff
  comment_lines 'config/environments/development.rb', /action_mailer/
  comment_lines 'config/environments/test.rb', /action_mailer/

  initializer 'action_mailer.rb', <<-CODE
  require "action_view/base"
    if ENV['DEFAULT_URL']
      if ::Rails::VERSION::STRING < '4.1'
        ExampleApp::Application.configure do
          config.action_mailer.default_url_options = { :host => ENV['DEFAULT_URL'] }
        end
      else
        Rails.application.configure do
          config.action_mailer.default_url_options = { :host => ENV['DEFAULT_URL'] }
        end
      end
    end

    if defined?(ActionMailer) && Rails::VERSION::MAJOR < 4
      # This will force the loading of ActionMailer settings
      ActionMailer::Base.smtp_settings
    end
  CODE
  gsub_file 'config/initializers/action_mailer.rb',
            /ExampleApp/,
            Rails.application.class.parent.to_s

  copy_file 'spec/support/default_preview_path'
  chmod 'spec/support/default_preview_path', 0755
  gsub_file 'spec/support/default_preview_path',
            /ExampleApp/,
            Rails.application.class.parent.to_s
  if skip_active_record?
    comment_lines 'spec/support/default_preview_path', /active_record/
    comment_lines 'spec/support/default_preview_path', /active_storage/
  end
  copy_file 'spec/verify_mailer_preview_path_spec.rb'
end
