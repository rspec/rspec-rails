Autotest.add_discovery do
  'rails' if File.exist? 'config/environment.rb'
end
