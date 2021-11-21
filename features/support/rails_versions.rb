def rails_version
  string_version = ENV.fetch("RAILS_VERSION", "~> 6.0.0")
  if string_version == "main" || string_version.nil?
    Float::INFINITY
  else
    string_version[/\d[\.-]\d/].tr('-', '.')
  end
end

Before "@rails_pre_6" do |scenario|
  if rails_version.to_f >= 6.0
    warn "Skipping scenario #{scenario.name} on Rails v#{rails_version}"
    skip_this_scenario
  end
end

Before "@rails_post_6" do |scenario|
  if rails_version.to_f < 6.0
    warn "Skipping scenario #{scenario.name} on Rails v#{rails_version}"
    skip_this_scenario
  end
end
