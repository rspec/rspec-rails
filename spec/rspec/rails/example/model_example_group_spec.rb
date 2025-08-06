module RSpec::Rails
  RSpec.describe ModelExampleGroup, :with_isolated_config do
    it_behaves_like "an rspec-rails example group mixin", :model,
                    './spec/models/', '.\\spec\\models\\'
  end
end
