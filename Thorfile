class Version < Thor
  desc "use VERSION", "installs the bundle the rails-VERSION"
  def use(version)
    `rm Gemfile.lock`
    `echo #{version} > ./.rails-version`
    "bundle install --binstubs".tap do |m|
      say m
      system m
    end
  end

  desc "which", "print out the configured rails version"
  def which
    say `cat ./.rails-version`
  end
end
