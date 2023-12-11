ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

module Connections
  def self.extended(host)
    fields =
      { host.primary_key => "integer PRIMARY KEY AUTOINCREMENT" }

    fields.merge!(host.connection_fields) if host.respond_to?(:connection_fields)

    host.connection.execute <<-EOSQL
      CREATE TABLE #{host.table_name} ( #{fields.map { |column, type| "#{column} #{type}"}.join(", ") })
    EOSQL

    host.reset_column_information
  end
end

class NonActiveRecordModel
  extend ActiveModel::Naming
  include ActiveModel::Conversion
end

class MockableModel < ActiveRecord::Base
  def self.connection_fields
    { associated_model_id: :integer }
  end
  extend Connections

  has_one :associated_model
end

class SubMockableModel < MockableModel
end

class AssociatedModel < ActiveRecord::Base
  def self.connection_fields
    { mockable_model_id: :integer, nonexistent_model_id: :integer }
  end
  extend Connections

  belongs_to :mockable_model
  belongs_to :nonexistent_model, class_name: "Other"
end

class AlternatePrimaryKeyModel < ActiveRecord::Base
  self.primary_key = :my_id
  extend Connections

  attr_accessor :my_id
end

module Namespaced
  class Model < ActiveRecord::Base
    def self.connection_fields
      { name: :string }
    end

    extend Connections
  end
end
