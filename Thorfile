class Rails < Thor
  desc "use VERSION", "installs the bundle using gemfiles/rails-VERSION"
  def use(version)
    gemfile = "--gemfile gemfiles/rails-#{version}"
    say `bundle install #{gemfile} --binstubs`
    say `bundle #{gemfile} update rails` unless version =~ /^\d\.\d\.\d$/
    say `ln -s gemfiles/bin` unless File.exist?('bin')
  end
end
