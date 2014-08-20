$LOAD_PATH.unshift('app')

require 'active_record'
require 'yaml'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

connection_info = YAML.load_file('config/database.yml')['test']
ActiveRecord::Base.establish_connection(connection_info)

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
