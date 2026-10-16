require 'rspec/support/spec/library_wide_checks'

RSpec.describe "RSpec::Rails" do
  include RSpec::Support::ShellOut
  include RSpec::Support::WhitespaceChecks

  # Pasted from rspec-support lib/rspec/support/spec/library_wide_checks.rb:134
  # Easier to do that here than to extract it out
  RSpec::Matchers.define :be_well_formed do
    match do |actual|
      actual.empty?
    end

    failure_message do |actual|
      actual.join("\n")
    end
  end

  it "has no malformed whitespace", :slow do
    error_messages = []
    `git ls-files -z`.split("\x0").each do |filename|
      error_messages << check_for_tab_characters(filename)
      error_messages << check_for_extra_spaces(filename)
    end
    expect(error_messages.compact).to be_well_formed
  end

  it "issues no warnings when loaded", :slow do
    lib_dir = File.expand_path("../../lib", __dir__)

    # generator templates are ERB so they can't be required
    script = <<~RUBY
      require 'rails/all'
      class LoadWarningsApp < Rails::Application; end
      require 'rails/generators'
      require 'rspec/rails'

      Dir["#{lib_dir}/**/*.rb"].each do |file|
        require file unless file.include?("/templates/")
      end
    RUBY

    _stdout, stderr, status = run_ruby_with_current_load_path(script, "-w")
    expect(status.exitstatus).to eq(0), stderr

    # ignore warnings from Rails and other gems, only check the ones from lib/
    warnings = stderr.lines(chomp: true).select do |line|
      line.include?("#{lib_dir}/") && line.include?("warning:")
    end
    expect(warnings).to be_well_formed
  end
end
