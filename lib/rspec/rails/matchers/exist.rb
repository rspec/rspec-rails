RSpec::Matchers.define :exist do
  match do |file_path|
    File.exists?(file_path)
  end
end
