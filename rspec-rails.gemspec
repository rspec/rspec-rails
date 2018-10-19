# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
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
  s.description = "rspec-rails is a testing framework for Rails 3+."

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

  version_string = ['>= 3.0']

  if RUBY_VERSION <= '1.8.7' && ENV['RAILS_VERSION'] != '3-2-stable'
    version_string << '!= 3.2.22.1'
  end

  s.add_runtime_dependency %q<activesupport>, version_string
  s.add_runtime_dependency %q<actionpack>,    version_string
  s.add_runtime_dependency %q<railties>,      version_string
  %w[core expectations mocks support].each do |name|
    if RSpec::Rails::Version::STRING =~ /[a-zA-Z]+/ # prerelease builds
      s.add_runtime_dependency "rspec-#{name}", "= #{RSpec::Rails::Version::STRING}"
    else
      s.add_runtime_dependency "rspec-#{name}", "~> #{RSpec::Rails::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
    end
  end

  s.add_development_dependency 'cucumber', '~> 1.3.5'
  s.add_development_dependency 'aruba',    '~> 0.5.4'
  s.add_development_dependency 'ammeter',  '~> 1.1.2'
end
