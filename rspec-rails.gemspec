# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/rails/version"

Gem::Specification.new do |s|
  s.name        = "rspec-rails"
  s.version     = RSpec::Rails::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["David Chelimsky", "Andy Lindeman"]
  s.email       = "rspec-users@rubyforge.org"
  s.homepage    = "http://github.com/rspec/rspec-rails"
  s.summary     = "rspec-rails-#{RSpec::Rails::Version::STRING}"
  s.description = "RSpec for Rails"

  s.rubyforge_project  = "rspec"

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.files           += %w[README.md License.txt Changelog.md Capybara.md .yardopts .document]
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.add_runtime_dependency(%q<activesupport>, [">= 3.0"])
  s.add_runtime_dependency(%q<activemodel>, [">= 3.0"])
  s.add_runtime_dependency(%q<actionpack>, [">= 3.0"])
  s.add_runtime_dependency(%q<railties>, [">= 3.0"])
  %w[core expectations mocks].each do |name|
    if RSpec::Rails::Version::STRING =~ /[a-zA-Z]+/ # prerelease builds
      s.add_runtime_dependency "rspec-#{name}", "= #{RSpec::Rails::Version::STRING}"
    else
      s.add_runtime_dependency "rspec-#{name}", "~> #{RSpec::Rails::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
    end
  end
  s.add_runtime_dependency "rspec-collection_matchers"

  s.add_development_dependency 'rake',     '~> 10.0.0'
  s.add_development_dependency 'cucumber', '~> 1.3.5'
  s.add_development_dependency 'aruba',    '~> 0.4.11'
  s.add_development_dependency 'ZenTest',  '4.9.0'
  s.add_development_dependency 'ammeter',  '0.2.5'
end
