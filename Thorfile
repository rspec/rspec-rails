class Rails < Thor
  desc "use VERSION", "configures the Gemfile and runs 'bundle install'"
  def use(version)
    `rm Gemfile.lock` if File.exist?('./Gemfile.lock')
    `rm Gemfile`      if File.exist?('./Gemfile')
    case version
    when /^\d\.\d/
      `echo 'instance_eval(File.read("./Gemfile-base"))' >> Gemfile`
      `echo 'gem "rails", "#{version}"' >> Gemfile`
    else
      `cp Gemfile-#{version} Gemfile` 
    end
    system "bundle install"
  end
end
