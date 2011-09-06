class Gemfile < Thor
  desc "use VERSION", "installs the bundle using gemfiles/rails-VERSION"
  def use(version)
    "rm #{lockfile(version)}".tap do |m|
      say m
      system m
    end
    with(version, %w[bundle install --binstubs])
    say `ln -s gemfiles/bin` unless File.exist?('bin')
    `echo rails-#{version} > ./.gemfile`
  end

  desc "with VERSION COMMAND", "executes COMMAND with the gemfile for VERSION"
  def with(version, *command)
    gemfile(version).tap do |gemfile|
      ENV["BUNDLE_GEMFILE"] = File.expand_path(gemfile)
      say "BUNDLE_GEMFILE=#{gemfile}"
    end
    command.join(' ').tap do |m|
      say m
      system m
    end
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

private

  def gemfile(version)
    "gemfiles/rails-#{version}"
  end

  def lockfile(version)
    gemfile(version) + ".lock"
  end
end
