module RSpec::Rails
  RSpec.describe JobExampleGroup, :with_isolated_config do
    if defined?(ActiveJob)
      it_behaves_like "an rspec-rails example group mixin", :job,
                      './spec/jobs/', '.\\spec\\jobs\\'
    end
  end
end
