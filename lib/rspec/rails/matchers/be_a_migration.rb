RSpec::Matchers.define :be_a_migration do
  match do |file_path|
    dirname, file_name = File.dirname(file_path), File.basename(file_path).sub(/\.rb$/, '')
    migration_file_path = Dir.glob("#{dirname}/[0-9]*_*.rb").grep(/\d+_#{file_name}.rb$/).first
    File.exist?(migration_file_path)
  end
end
