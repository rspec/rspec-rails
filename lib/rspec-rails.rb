module RSpec
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "rspec/rails/tasks/rspec.rake"
      end
    end
  end
end