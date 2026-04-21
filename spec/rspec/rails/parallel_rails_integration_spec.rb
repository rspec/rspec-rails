require "fileutils"

# End-to-end integration: boot a real Rails app, run it under
# `rspec --parallel 2`, and assert per-worker SQLite databases were
# created. Opted in via RSPEC_RAILS_FULL_INTEGRATION=1 because the
# `bundle install` + two-worker run is slow relative to the rest of
# the suite.
RSpec.describe "rspec-rails parallel end-to-end with a real Rails app" do
  let(:app_path) { File.expand_path("../../fixtures/parallel_app", __dir__) }

  before do
    skip "set RSPEC_RAILS_FULL_INTEGRATION=1 to run" unless ENV["RSPEC_RAILS_FULL_INTEGRATION"]
    skip "fork() unavailable on this platform"       unless Process.respond_to?(:fork)

    FileUtils.rm_f(Dir[File.join(app_path, "db", "*.sqlite3*")])
    FileUtils.rm_f(Dir[File.join(app_path, "log", "*.log")])
    FileUtils.rm_f(File.join(app_path, "Gemfile.lock"))
  end

  def run!(cmd)
    output = `#{cmd} 2>&1`
    raise "command failed (#{$?.exitstatus}): #{cmd}\n#{output}" unless $?.success?

    output
  end

  it "creates a per-worker SQLite database and both workers succeed" do
    Bundler.with_unbundled_env do
      Dir.chdir(app_path) do
        run!("bundle install --quiet")
        output = `bundle exec rspec --parallel=2 2>&1`
        expect($?.exitstatus).to eq(0), "rspec --parallel=2 failed:\n#{output}"

        sqlite_files = Dir["db/test*.sqlite3*"].grep(/[-_]\d+(\.sqlite3)?\z/)
        expect(sqlite_files.size).to eq(2), "expected 2 per-worker DBs, got #{Dir['db/*'].inspect}"
      end
    end
  end
end
