begin
  require "active_job"
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

require "rspec/rails/feature_check"

Then /^the example(s)? should( all)? pass$/ do |_, _|
  step %q{the output should contain "0 failures"}
  step %q{the exit status should be 0}
end

Given /active job is available/ do
  if !RSpec::Rails::FeatureCheck.has_active_job?
    pending "ActiveJob is not available"
  end
end
