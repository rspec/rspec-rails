begin
  require "active_job"
rescue LoadError # rubocop:disable Lint/HandleExceptions
end
require "rails/version"

require "rspec/rails/feature_check"

Then /^the example(s)? should( all)? pass$/ do |_, _|
  step %q(the output should contain "0 failures")
  step %q(the exit status should be 0)
end

Then /^the example(s)? should( all)? fail/ do |_, _|
  step %q(the output should not contain "0 failures")
  step %q(the exit status should not be 0)
end

Given /active job is available/ do
  unless RSpec::Rails::FeatureCheck.has_active_job?
    pending "ActiveJob is not available"
  end
end

Given /file fixtures are available/ do
  unless RSpec::Rails::FeatureCheck.has_file_fixture?
    pending "file fixtures are not available"
  end
end
