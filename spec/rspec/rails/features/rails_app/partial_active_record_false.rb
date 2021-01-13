require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", (ENV["RAILS_VERSION"] || "~> 6.0.0")
  gem "rspec-rails", path: "./"
  gem "sqlite3"
  gem "ammeter"
end

require "active_record/railtie"

require "ammeter"
require "rspec/autorun"
require "rspec/rails"

class Command
end

RSpec.configure do |config|
  config.use_active_record = false
end

RSpec.describe Command do
  it 'should not break' do
    Command.new
  end
end
