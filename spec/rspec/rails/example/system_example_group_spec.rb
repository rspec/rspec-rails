require "spec_helper"

if defined?(RSpec::Rails::SystemExampleGroup)
  RSpec.describe RSpec::Rails::SystemExampleGroup do
    it_behaves_like "an rspec-rails example group mixin", :system,
      './spec/system/', '.\\spec\\system\\'
  end
end
