Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false if config.respond_to?(:action_controller)
  config.action_dispatch.show_exceptions = :none if config.action_dispatch.respond_to?(:show_exceptions=)
  config.active_support.deprecation = :stderr
end
