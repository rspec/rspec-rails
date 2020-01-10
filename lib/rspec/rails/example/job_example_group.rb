module RSpec
  module Rails
    # Container module for job spec functionality.
    module JobExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
    end
  end
end
