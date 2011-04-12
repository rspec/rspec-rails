Feature: generator spec

  Generator specs live in spec/generators. In order to access
  the generator's methods you can call them on the "generator" object.

  Background: A simple generator
    Given a file named "lib/generators/awesome/awesome_generator.rb" with:
      """
      class AwesomeGenerator < Rails::Generators::NamedBase
        source_root File.expand_path('../templates', __FILE__)

        def create_awesomeness
          template 'awesome.html', File.join('public', name, 'awesome.html')
        end

        def create_lameness
          template 'lame.html', File.join('public', name, 'lame.html')
        end
      end
      """
    And a file named "lib/generators/awesome/templates/awesome.html" with:
      """
      This is an awesome file
      """
    And a file named "lib/generators/awesome/templates/lame.html" with:
      """
      This is a lame file
      """

  Scenario: A spec that runs the entire generator
    Given a file named "spec/generators/awesome_generator_spec.rb" with:
      """
      require "spec_helper"

      require 'rails/generators'
      require 'generators/awesome/awesome_generator'

      describe AwesomeGenerator do
        destination File.expand_path("../../tmp", __FILE__)

        before do
          run_generator %w(my_dir)
        end
        it 'should copy the awesome file into public' do
          absolute_filename('public/my_dir/awesome.html').should be_generated
        end
        it 'should copy the lame file into public' do
          absolute_filename('public/my_dir/lame.html').should be_generated
        end
      end
      """
    When I run `rspec spec/generators/awesome_generator_spec.rb`
    Then the output should contain "2 examples, 0 failures"

    Scenario: A spec that runs one task in the generator
      Given a file named "spec/generators/another_awesome_generator_spec.rb" with:
        """
        require "spec_helper"

        require 'rails/generators'
        require 'generators/awesome/awesome_generator'

        describe AwesomeGenerator do
          destination File.expand_path("../../tmp", __FILE__)
          arguments %w(another_dir)

          before do
            invoke_task :create_awesomeness
          end
          it 'should copy the awesome file into public' do
            absolute_filename('public/another_dir/awesome.html').should be_generated
          end
          it 'should not have copied the lame file into public' do
            absolute_filename('public/another_dir/lame.html').should_not be_generated
          end
        end
        """
      When I run `rspec spec/generators/another_awesome_generator_spec.rb`
      Then the output should contain "2 examples, 0 failures"