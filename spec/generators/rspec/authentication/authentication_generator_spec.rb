# Generators are not automatically loaded by Rails
require 'generators/rspec/authentication/authentication_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::AuthenticationGenerator, type: :generator do
  setup_default_destination

  it 'runs the model, fixture, and request spec tasks' do
    gen = generator
    expect(gen).to receive :create_user_spec
    expect(gen).to receive :create_fixture_file
    expect(gen).to receive :create_session_request_spec
    expect(gen).to receive :create_password_request_spec
    expect(gen).to receive :create_authentication_support
    expect(gen).to receive :configure_authentication_support
    gen.invoke_all
  end

  describe 'the generated files' do
    it 'creates the user spec' do
      run_generator

      expect(File.exist?(file('spec/models/user_spec.rb'))).to be true
    end

    it 'creates the request specs' do
      run_generator

      expect(File.exist?(file('spec/requests/sessions_spec.rb'))).to be true
      expect(File.exist?(file('spec/requests/passwords_spec.rb'))).to be true
    end

    it 'configures the authentication support' do
      # Create a minimal rails_helper.rb file that the generator can modify
      FileUtils.mkdir_p(File.join(destination_root, 'spec'))
      rails_helper_content = <<~CONTENT
        # Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }
        RSpec.configure do |config|
        end
      CONTENT
      File.write(File.join(destination_root, 'spec', 'rails_helper.rb'), rails_helper_content)

      run_generator

      expect(file('spec/rails_helper.rb')).to contain(
        "  # Include authentication support module for request specs\n  config.include AuthenticationSupport, type: :request\n"
      )
      expect(file('spec/rails_helper.rb')).not_to contain(
        "  # Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }\n"
      )

      expect(File.exist?(file('spec/support/authentication_support.rb'))).to be true
    end

    describe 'with request specs disabled' do
      before do
        run_generator ['--request-specs=false']
      end

      describe 'the request specs' do
        it "will skip the files" do
          expect(File.exist?(file('spec/requests/sessions_spec.rb'))).to be false
          expect(File.exist?(file('spec/requests/passwords_spec.rb'))).to be false
        end
      end
    end

    describe 'with fixture replacement' do
      before do
        run_generator ['--fixture-replacement=factory_bot']
      end

      describe 'the fixtures' do
        it "will skip the file" do
          expect(File.exist?(file('spec/fixtures/users.yml'))).to be false
        end
      end
    end
  end
end
