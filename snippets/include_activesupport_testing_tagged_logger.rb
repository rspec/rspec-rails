if __FILE__ =~ /^snippets/
  fail "Snippets are supposed to be run from their own directory to avoid side " \
       "effects as e.g. the root `Gemfile`, or `spec/spec_helpers.rb` to be " \
       "loaded by the root `.rspec`."
end

# We opt-out from using RubyGems, but `bundler/inline` requires it
require 'rubygems'

require "bundler/inline"

# We pass `false` to `gemfile` to skip the installation of gems,
# because it may install versions that would conflict with versions
# from the main `Gemfile.lock`.
gemfile(false) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # Those Gemfiles carefully pick the right versions depending on
  # settings in the ENV, `.rails-version` and `maintenance-branch`.
  Dir.chdir('..') do
    # This Gemfile expects `maintenance-branch` file to be present
    # in the current directory.
    eval_gemfile 'Gemfile-rspec-dependencies'
    # This Gemfile expects `.rails-version` file
    eval_gemfile 'Gemfile-rails-dependencies'
  end

  gem "rspec-rails", path: "../"
end

# Run specs at exit
require "rspec/autorun"

require "rails"
require "active_record/railtie"
require "active_job/railtie"
require "rspec/rails"

ActiveJob::Base.queue_adapter = :test

# This connection will do for database-independent bug reports
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

class TestError < StandardError; end

class TestJob < ActiveJob::Base
  def perform
    raise TestError
  end
end

RSpec.describe 'Foo', type: :job do
  include ::ActiveJob::TestHelper

  describe 'error raised in perform_enqueued_jobs with block' do
    it 'raises the explicitly thrown error' do
      # Rails 6.1+ wraps unexpected errors in tests
      expected_error = if Rails::VERSION::STRING.to_f >= 6.1
                         Minitest::UnexpectedError.new(TestError)
                       else
                         TestError
                       end

      expect { perform_enqueued_jobs { TestJob.perform_later } }
        .to raise_error(expected_error)
    end
  end
end
