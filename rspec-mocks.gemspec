# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rspec-mocks}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Chelimsky", "Chad Humphries"]
  s.date = %q{2009-06-29}
  s.email = %q{dchelimsky@gmail.com;chad.humphries@gmail.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "License.txt",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "lib/rspec-expectations.rb",
     "rspec-mocks.gemspec",
     "spec/rspec-expectations_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/rspec/mocks}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{TODO.markdown License.txt README.markdown}
  s.test_files = [
    "spec/rspec-expectations_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
