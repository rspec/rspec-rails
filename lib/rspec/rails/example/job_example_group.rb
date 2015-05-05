module RSpec
  module Rails
    # Container class for job spec functionality. Does not provide anything
    # special over the common RailsExampleGroup currently.
    module JobExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
    end
  end
end
