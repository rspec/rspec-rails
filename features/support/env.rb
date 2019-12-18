require 'aruba/cucumber'
require 'fileutils'

module ArubaExt
  def run(cmd, timeout = nil)
    exec_cmd = cmd =~ /^rspec/ ? "bin/#{cmd}" : cmd
    super(exec_cmd, timeout)
  end
  # This method over rides Aruba 0.5.4 implementation so that we can reset Bundler to use the sample app Gemfile
  def in_current_dir(&block)
    Bundler.with_clean_env do
      _mkdir(current_dir)
      Dir.chdir(current_dir, &block)
    end
  end
end

World(ArubaExt)

Before do
  @aruba_timeout_seconds = 30
end

unless File.directory?('./tmp/example_app')
  system "rake generate:app generate:stuff"
end

Before do
  example_app_dir = 'tmp/example_app'
  # Per default Aruba will create a directory tmp/aruba where it performs its file operations.
  # https://github.com/cucumber/aruba/blob/v0.6.1/README.md#use-a-different-working-directory
  aruba_dir = 'tmp/aruba'

  # Remove the previous aruba workspace.
  FileUtils.rm_rf(aruba_dir) if File.exist?(aruba_dir)

  # We want fresh `example_app` project with empty `spec` dir except helpers.
  # FileUtils.cp_r on Ruby 1.9.2 doesn't preserve permissions.
  system('cp', '-r', example_app_dir, aruba_dir)
  helpers = %w[spec/spec_helper.rb spec/rails_helper.rb]
  Dir["#{aruba_dir}/spec/*"].each do |path|
    next if helpers.any? { |helper| path.end_with?(helper) }
    FileUtils.rm_rf(path)
  end
end
