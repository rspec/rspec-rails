Before('@remove-generator-files') do
  command = <<-COMMAND
  rm -f \
    tmp/example_app/lib/generators/my_generator \
    tmp/example_app/lib/generators/my_generator/my_generator_generator.rb \
    tmp/example_app/lib/generators/my_generator/USAGE \
    tmp/example_app/lib/generators/my_generator/templates \
    tmp/example_app/spec/generator/my_generator_spec.rb
  COMMAND
  system(command)
end
