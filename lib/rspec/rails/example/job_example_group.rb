module RSpec
  module Rails
    # Container module for job spec functionality. It is only available if
    # ActiveJob has been loaded before it.
    module JobExampleGroup
    end
  end
end

if defined?(ActiveJob)
  module RSpec
    module Rails
      # Container module for job spec functionality.
      module JobExampleGroup
        extend ActiveSupport::Concern
        include RSpec::Rails::RailsExampleGroup
      end
    end
  end
end
