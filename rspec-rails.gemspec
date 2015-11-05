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
  s.homepage    = "http://github.com/rspec/rspec-rails"
  s.summary     = "RSpec for Rails"
  s.description = "rspec-rails is a testing framework for Rails 3.x and 4.x."

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += %w[README.md License.md Changelog.md Capybara.md .yardopts .document]
  s.test_files       = []
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  private_key = File.expand_path('~/.gem/rspec-gem-private_key.pem')
  if File.exist?(private_key)
    s.signing_key = private_key
    s.cert_chain = [File.expand_path('~/.gem/rspec-gem-public_cert.pem')]
  end

  s.add_runtime_dependency %q<activesupport>, ">= 3.0"
  s.add_runtime_dependency %q<actionpack>,    ">= 3.0"
  s.add_runtime_dependency %q<railties>,      ">= 3.0"
  %w[core expectations mocks support].each do |name|
    if RSpec::Rails::Version::STRING =~ /[a-zA-Z]+/ # prerelease builds
      s.add_runtime_dependency "rspec-#{name}", "= #{RSpec::Rails::Version::STRING}"
    else
      s.add_runtime_dependency "rspec-#{name}", "~> #{RSpec::Rails::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
    end
  end

  s.add_development_dependency 'rake',     '~> 10.0.0'
  s.add_development_dependency 'cucumber', '~> 1.3.5'
  s.add_development_dependency 'aruba',    '~> 0.5.4'
  s.add_development_dependency 'ammeter',  '1.1.2'
end
