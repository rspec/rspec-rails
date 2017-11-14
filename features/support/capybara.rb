Around "@capybara" do |_scenario, block|
  # We are caught in a weird situation here. rspec-rails supports 1.8.7 and
  # above, but capybara beyond a certain version only supports 1.9.3 and above.
  # On 1.8.7 and 1.9.2, we run most of the rspec-rails test suite but leave out
  # parts that require capybara.
  if RUBY_VERSION >= '1.9.3'
    require 'capybara'
    block.call
  end
end
