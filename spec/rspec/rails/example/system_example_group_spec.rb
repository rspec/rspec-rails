require "spec_helper"
module RSpec::Rails
  if defined?(SystemExampleGroup)
    RSpec.describe SystemExampleGroup do
      it_behaves_like "an rspec-rails example group mixin", :system,
        './spec/system/', '.\\spec\\system\\'
    end
  end
end
