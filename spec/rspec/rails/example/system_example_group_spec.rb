require "spec_helper"
module RSpec::Rails
  if ActionPack::VERSION::STRING >= "5.1"
    RSpec.describe SystemExampleGroup do
      it_behaves_like "an rspec-rails example group mixin", :system,
        './spec/system/', '.\\spec\\system\\'
    end
  end
end
