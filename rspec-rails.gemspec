$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require "rspec/rails/version"

Gem::Specification.new do |s|
  s.name        = "rspec-rails"
  s.version     = RSpec::Rails::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["David Chelimsky", "Andy Lindeman"]
  s.email       = "rspec@googlegroups.com"
  s.homepage    = "https://github.com/rspec/rspec-rails"
  s.summary     = "RSpec for Rails"
  s.description = "rspec-rails is a testing framework for Rails 5+."
  s.required_ruby_version = ">= 2.5.0"

  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/rspec/rspec-rails/issues',
    'changelog_uri'     => "https://github.com/rspec/rspec-rails/blob/v#{s.version}/Changelog.md",
    'documentation_uri' => 'https://rspec.info/documentation/',
    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/rspec',
    'source_code_uri'   => 'https://github.com/rspec/rspec-rails',
  }

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += %w[README.md LICENSE.md Changelog.md Capybara.md .yardopts .document]
  s.test_files       = []
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  if File.exist?(private_key)
    s.signing_key = private_key
    s.cert_chain = [File.expand_path('~/.gem/rspec-gem-public_cert.pem')]
  end

  version_string = ['>= 6.1']

  s.add_runtime_dependency 'actionpack',    version_string
  s.add_runtime_dependency 'activesupport', version_string
  s.add_runtime_dependency 'railties',      version_string

  # in these blocks expected_rspec_version is set up to track the released
  # versions of RSpec. RSpec Rails does not have lock step versioning with the
  # rest of RSpec after version 4.0.0, so this sets up the correct dev versions
  # that we want. These will need to change from time to time as new RSpecs
  # get released.
  %w[core expectations mocks support].each do |name|
    if ENV['RSPEC_CI']
      s.add_runtime_dependency "rspec-#{name}", ENV.fetch('RSPEC_VERSION', '3.12.0.pre')
    elsif RSpec::Rails::Version::STRING =~ /pre/ # prerelease builds
      expected_rspec_version = "3.12.0.pre"
      s.add_runtime_dependency "rspec-#{name}", "= #{expected_rspec_version}"
    else
      expected_rspec_version = "3.11.0"
      s.add_runtime_dependency "rspec-#{name}", "~> #{expected_rspec_version.split(".")[0..1].join(".")}"
    end
  end

  s.add_development_dependency 'ammeter',  '~> 1.1.5'
  s.add_development_dependency 'aruba',    '~> 0.14.12'
  s.add_development_dependency 'cucumber', '>= 3.2', '!= 4.0.0', '< 8.0.0'
end
