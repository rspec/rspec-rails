if Rails.application.config.respond_to?(:active_record)
  Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true
end
