# Generators are not automatically loaded by Rails
require 'generators/rspec/authentication/authentication_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::AuthenticationGenerator, type: :generator do
  setup_default_destination

  it 'runs both the model and fixture tasks' do
    gen = generator
    expect(gen).to receive :create_user_spec
    expect(gen).to receive :create_fixture_file
    gen.invoke_all
  end

  it 'runs the request spec tasks' do
    gen = generator
    expect(gen).to receive :create_session_request_spec
    expect(gen).to receive :create_password_request_spec
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
