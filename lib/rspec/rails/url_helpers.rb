module RSpec::Rails
  module UrlHelpers
    DEFAULT_HOST = "www.example.com"

    def self.included(base)
      app = ::Rails.application
      if app.respond_to?(:routes)
        base.class_eval do
          include app.routes.url_helpers if app.routes.respond_to?(:url_helpers)
          include app.routes.mounted_helpers if app.routes.respond_to?(:mounted_helpers)
        end

        if base.respond_to?(:default_url_options)
          base.default_url_options[:host] ||= ::RSpec::Rails::UrlHelpers::DEFAULT_HOST
        end
      end
    end
  end
end
