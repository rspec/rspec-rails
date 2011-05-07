class Gemfile < Thor
  desc "use VERSION", "installs the bundle using gemfiles/rails-VERSION"
  def use(version)
    gemfile = "--gemfile gemfiles/rails-#{version}"
    say `bundle install #{gemfile} --binstubs`
    say `bundle #{gemfile} update rails` unless version =~ /^\d\.\d\.\d$/
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
