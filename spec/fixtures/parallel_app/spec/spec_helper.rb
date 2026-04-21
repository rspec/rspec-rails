RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true if expectations.respond_to?(:include_chain_clauses_in_custom_matcher_descriptions=)
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus
  config.disable_monkey_patching! if config.respond_to?(:disable_monkey_patching!)
  config.order = :random
  Kernel.srand config.seed
end
