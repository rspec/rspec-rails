module RSpec::Rails
  module FeatureExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup

    included do
      metadata[:type] = :feature

      include Rails.application.routes.url_helpers
    end
  end
end
