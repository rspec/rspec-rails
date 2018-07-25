FileUtils.rm_f('./test.db')

def establish_active_record_connection
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => './test.db'
  )
end

def clear_active_record_connection
  ActiveRecord::Base.connection_handler.clear_all_connections!
  ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
    if Rails.version.to_f >= 5.0
      ActiveRecord::Base.connection_handler.remove_connection(pool.spec.name)
    else
      ActiveRecord::Base.connection_handler.remove_connection(ActiveRecord::Base)
    end
  end
end

establish_active_record_connection

module Connections
  def self.extended(host)
    host.connection.execute <<-eosql
      CREATE TABLE #{host.table_name} (
        #{host.primary_key} integer PRIMARY KEY AUTOINCREMENT,
        associated_model_id integer,
        mockable_model_id integer,
        nonexistent_model_id integer
      )
    eosql

    host.reset_column_information
  end
end

class NonActiveRecordModel
  extend ActiveModel::Naming
  include ActiveModel::Conversion
end

class MockableModel < ActiveRecord::Base
  extend Connections
  has_one :associated_model
end

class SubMockableModel < MockableModel
end

class AssociatedModel < ActiveRecord::Base
  extend Connections
  belongs_to :mockable_model
  belongs_to :nonexistent_model, :class_name => "Other"
end

class AlternatePrimaryKeyModel < ActiveRecord::Base
  self.primary_key = :my_id
  extend Connections
  attr_accessor :my_id
end
