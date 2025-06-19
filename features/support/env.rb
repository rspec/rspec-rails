require 'aruba/cucumber'
require 'fileutils'

module ArubaExt
  def run_command_and_stop(cmd, opts = {})
    exec_cmd = cmd =~ /^rspec/ ? "bin/#{cmd}" : cmd

    unset_bundler_env_vars
    # Ensure the correct Gemfile and binstubs are found
    in_current_directory do
      with_unbundled_env do
        super(exec_cmd, opts)
      end
    end
  end

  def unset_bundler_env_vars
    empty_env = with_environment { with_unbundled_env { ENV.to_h } }
    aruba_env = aruba.environment.to_h
    (aruba_env.keys - empty_env.keys).each do |key|
      delete_environment_variable key
    end
    empty_env.each do |k, v|
      set_environment_variable k, v
    end
  end

  def with_unbundled_env
    if Bundler.respond_to?(:with_unbundled_env)
      Bundler.with_unbundled_env { yield }
    else
      Bundler.with_clean_env { yield }
    end
  end
end

World(ArubaExt)

Aruba.configure do |config|
  if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'truffleruby'
    config.exit_timeout = 120
  else
    config.exit_timeout = 30
  end
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
  directories = []

  Dir["#{aruba_dir}/spec/**/*"].each do |path|
    next if helpers.any? { |helper| path.end_with?(helper) }

    # Because we now check for things like spec/support we only want to delete empty directories
    if File.directory?(path)
      directories << path
      next
    end

    FileUtils.rm_rf(path)
  end

  directories.each { |dir| FileUtils.rm_rf(dir) if Dir.empty?(dir) }
end
