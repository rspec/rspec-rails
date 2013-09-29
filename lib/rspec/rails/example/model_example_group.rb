module RSpec::Rails
  module ModelExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup

    included do
      metadata[:type] = :model
      hooks.register_globals(self, RSpec.configuration.hooks)
    end
  end
end
