require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rspec/rails"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  # Parallel bridge auto-wires on `require "rspec/rails"` -- no explicit
  # opt-in needed. Kept minimal to mirror a real generated rails_helper.rb.
end
