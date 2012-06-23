module RSpec
  class EngineExample < ::Rails::Engine
    def self.activate
    end
  end

  if RSpec::Rails.at_least_rails_3_1?
    EngineExample.routes.draw do
      root :to => "foo#index"
      resources :bars
    end
  end
end
