# Rails 4.0.x seems to be the only version that does not autoload `ActiveModel`
require 'active_model'

raise "ActiveRecord is defined but should not be!" if defined?(::ActiveRecord)

module InMemory
  module Persistence
    def all
      @all_records ||= []
    end

    def count
      all.length
    end
    alias_method :size, :count
    alias_method :length, :count

    def create!(attributes = {})
      with_id = { :id => next_id, :persisted => true }
      all << record = new(with_id.merge(attributes))
      record
    end

    def next_id
      @id_count ||= 0
      @id_count += 1
    end
  end

  class Model
    extend Persistence

    if defined?(::ActiveModel::Model)
      include ::ActiveModel::Model
    else
      extend ::ActiveModel::Naming
      include ::ActiveModel::Conversion
      include ::ActiveModel::Validations

      def initialize(attributes = {})
        attributes.each do |name, value|
          send("#{name}=", value)
        end
      end
    end

    attr_accessor :id, :persisted

    alias_method :persisted?, :persisted

    def new_record?
      !persisted?
    end

    def to_param
      id.to_s
    end
  end
end
