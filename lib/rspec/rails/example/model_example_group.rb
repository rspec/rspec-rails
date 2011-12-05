module RSpec::Rails
  # The basis for model specs
  module ModelExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup

    included do
      metadata[:type] = :model
    end
  end
end
