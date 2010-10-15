class Rails < Thor
  VERSIONS = {
    :rails => {
      "master" => "master",
      "3.0.0" => "v3.0.0",
      "3.0.1" => "v3.0.1",
      "3-0-stable" => "origin/3-0-stable"
    },
    :arel => {
      "master" => "master",
      "3.0.0" => "v1.0.0",
      "3.0.1" => "v1.0.0",
      "3-0-stable" => "master"
    }
  }

  desc "checkout VERSION", "checks it out (and arel)"
  def checkout(version)
    unless VERSIONS[:rails].has_key?(version)
      raise "\n#{"*"*50}\nvalid versions are: #{VERSIONS[:rails].keys.join(", ")}\n#{"*"*50}\n"
    end

    puts "***** checking out rails at #{VERSIONS[:rails][version]} ..."
    Dir.chdir("vendor/rails") do
      `git checkout #{VERSIONS[:rails][version]}`
    end

    puts "***** checking out arel at #{VERSIONS[:arel][version]} ..."
    Dir.chdir("vendor/arel") do
      `git checkout #{VERSIONS[:arel][version]}`
    end
  end

  desc "fetch", "update vendor/rails and vendor/arel"
  def fetch
    Dir.chdir("vendor/rails") do
      `git fetch`
    end
    Dir.chdir("vendor/arel") do
      `git fetch`
    end
  end
end
