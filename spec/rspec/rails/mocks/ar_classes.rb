module NoConnections
  def self.included(mod)
    (class << mod; self; end).class_eval do
      def columns
        []
      end

      def connection
        RSpec::Mocks::Mock.new.as_null_object
      end
    end
  end
end

class MockableModel < ActiveRecord::Base
  include NoConnections
  has_one :associated_model
end

class SubMockableModel < MockableModel
end

class AssociatedModel < ActiveRecord::Base
  include NoConnections
  belongs_to :mockable_model
end
