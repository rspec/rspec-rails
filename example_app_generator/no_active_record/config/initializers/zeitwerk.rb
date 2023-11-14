if Rails.autoloaders.respond_to?(:main) && Rails.autoloaders.main.respond_to?(:ignore)
  Rails.autoloaders.main.ignore('lib/rails/generators/in_memory/model/model_generator.rb')
end
