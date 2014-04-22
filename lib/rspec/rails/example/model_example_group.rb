module RSpec::Rails
  module ModelExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
  end
end
