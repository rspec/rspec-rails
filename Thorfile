class Gemfile < Thor
  desc "use VERSION", "installs the bundle using gemfiles/rails-VERSION"
  def use(version)
    "gemfiles/rails-#{version}".tap do |gemfile|
      ENV["BUNDLE_GEMFILE"] = File.expand_path(gemfile)
      say "Using #{gemfile}"
    end
    "bundle install --binstubs".tap do |m|
      say m
      system m
    end
    unless version =~ /^\d\.\d\.\d/
      "bundle update rails".tap do |m|
        say m
        system m
      end
    end
    say `ln -s gemfiles/bin` unless File.exist?('bin')
    `echo rails-#{version} > ./.gemfile`
  end

  desc "which", "print out the configured gemfile"
  def which
    say `cat ./.gemfile`
  end

  desc "list", "list the available options for 'thor gemfile:use'"
  def list
    all = `ls gemfiles`.chomp.split.grep(/^rails/).reject {|i| i =~ /lock$/}

    versions = all.grep(/^rails-\d\.\d/)
    branches = all - versions

    puts "releases:"
    versions.sort.reverse.each {|i| puts i}
    puts
    puts "branches:"
    branches.sort.reverse.each {|i| puts i}
  end
end
