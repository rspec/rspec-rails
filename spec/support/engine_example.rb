module RSpec
  class EngineExample < ::Rails::Engine
    def self.activate
    end
  end
end


RSpec::EngineExample.routes.draw do
  root :to => "foo#index"
  resources :bars
end
