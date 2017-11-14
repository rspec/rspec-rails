require "spec_helper"
require 'rspec/support/spec/in_sub_process'

RSpec.describe "Configuration" do
  include RSpec::Support::InSubProcess

  subject(:config) { RSpec::Core::Configuration.new }

  before do
    RSpec::Rails.initialize_configuration(config)
  end

  it "adds 'vendor/' to the backtrace exclusions" do
    expect(config.backtrace_exclusion_patterns).to include(/vendor\//)
  end

  it "adds 'lib/rspec/rails' to the backtrace exclusions" do
    expect(
      config.backtrace_exclusion_patterns
    ).to include(%r{lib/rspec/rails})
  end

  shared_examples_for "adds setting" do |accessor, opts|
    opts ||= {}
    default_value = opts[:default]
    alias_setting = opts[:alias_with]
    query_method = "#{accessor}?".to_sym
    command_method = "#{accessor}=".to_sym

    specify "`##{query_method}` is `#{default_value.inspect}` by default" do
      expect(config.send(query_method)).to be(default_value)
    end

    describe "`##{command_method}`" do
      it "changes `#{query_method}` to the provided value" do
        expect do
          config.send(command_method, :a_value)
        end.to change { config.send(query_method) }.to(:a_value)
      end

      it "sets `#{accessor}` to the provided value" do
        expect do
          config.send(command_method, :a_value)
        end.to change {
          config.send(accessor)
        }.from(default_value).to(:a_value)
      end
    end

    if alias_setting
      specify "`##{alias_setting}` is an alias for `#{accessor}`" do
        expect do
          config.send(command_method, :a_value)
        end.to change { config.send(alias_setting) }.to(:a_value)
      end
    end
  end

  context "adds settings" do
    include_examples "adds setting",
                     :infer_base_class_for_anonymous_controllers,
                     :default => true

    include_examples "adds setting",
                     :use_transactional_fixtures,
                     :alias_with => :use_transactional_examples

    include_examples "adds setting", :use_instantiated_fixtures

    include_examples "adds setting", :global_fixtures

    include_examples "adds setting", :fixture_path

    include_examples "adds setting", :rendering_views

    specify "`#render_views?` is falsey by default" do
      expect(config.render_views?).to be_falsey
    end

    specify "`#render_views` sets `render_views?` to `true`" do
      expect do
        config.render_views
      end.to change { config.render_views? }.to be(true)
    end

    describe "`#render_views=`" do
      it "sets `render_views?` to the provided value" do
        expect do
          config.render_views = false
        end.to change { config.render_views? }.from(nil).to(false)
      end

      it "sets `render_views` to the provided value" do
        expect do
          config.render_views = :a_value
        end.to change { config.render_views? }.to(:a_value)
      end
    end
  end

  specify "#filter_rails_from_backtrace! adds exclusion patterns for rails gems" do
    config.filter_rails_from_backtrace!

    gems = %w[
      actionmailer
      actionpack
      actionview
      activemodel
      activerecord
      activesupport
      activejob
    ]
    exclusions = config.backtrace_exclusion_patterns.map(&:to_s)
    aggregate_failures do
      gems.each { |gem| expect(exclusions).to include(/#{gem}/) }
    end
  end

  describe "#infer_spec_type_from_file_location!" do
    def in_inferring_type_from_location_environment
      in_sub_process do
        RSpec.configuration.infer_spec_type_from_file_location!
        yield
      end
    end

    shared_examples_for "infers type from location" do |type, location|
      it "sets the type to `#{type.inspect}` for file path `#{location}`" do
        in_inferring_type_from_location_environment do
          allow(RSpec::Core::Metadata).to receive(:relative_path).and_return(
            "./#{location}/foos_spec.rb"
          )
          group = RSpec.describe("Arbitrary Description")
          expect(group.metadata).to include(:type => type)
        end
      end
    end

    include_examples "infers type from location",
                     :controller,
                     "spec/controllers"
    include_examples "infers type from location", :helper, "spec/helpers"
    include_examples "infers type from location", :mailer, "spec/mailers"
    include_examples "infers type from location", :model, "spec/models"
    include_examples "infers type from location", :request, "spec/requests"
    include_examples "infers type from location", :request, "spec/integration"
    include_examples "infers type from location", :request, "spec/api"
    include_examples "infers type from location", :routing, "spec/routing"
    include_examples "infers type from location", :view, "spec/views"
    include_examples "infers type from location", :feature, "spec/features"
  end

  it "fixture support is included with metadata `:use_fixtures`" do
    in_sub_process do
      RSpec.configuration.global_fixtures = [:foo]
      RSpec.configuration.fixture_path = "custom/path"

      group = RSpec.describe("Arbitrary Description", :use_fixtures)

      expect(group).to respond_to(:fixture_path)
      expect(group.fixture_path).to eq("custom/path")
      expect(group.new.respond_to?(:foo, true)).to be(true)
    end
  end

  it "metadata `:type => :controller` sets up controller example groups" do
    a_controller_class = Class.new
    stub_const "SomeController", a_controller_class

    group = RSpec.describe(SomeController, :type => :controller)

    expect(group.controller_class).to be(a_controller_class)
    expect(group.new).to be_a(RSpec::Rails::ControllerExampleGroup)
  end

  it "metadata `:type => :helper` sets up helper example groups" do
    a_helper_module = Module.new
    stub_const "SomeHelper", a_helper_module

    group = RSpec.describe(SomeHelper, :type => :helper)

    expect(
      group.determine_default_helper_class(:ignored)
    ).to be(a_helper_module)
    expect(group.new).to be_a(RSpec::Rails::HelperExampleGroup)
  end

  it "metadata `:type => :model` sets up model example groups" do
    a_model_class = Class.new
    stub_const "SomeModel", a_model_class

    group = RSpec.describe(SomeModel, :type => :model)

    expect(group.new).to be_a(RSpec::Rails::ModelExampleGroup)
  end

  it "metadata `:type => :request` sets up request example groups" do
    a_rails_app = double("Rails application")
    the_rails_module = Module.new
    allow(the_rails_module).to receive(:application) { a_rails_app }
    version = ::Rails::VERSION
    stub_const "Rails", the_rails_module
    stub_const 'Rails::VERSION', version

    group = RSpec.describe("Some Request API", :type => :request)

    expect(group.new.app).to be(a_rails_app)
    expect(group.new).to be_a(RSpec::Rails::RequestExampleGroup)
  end

  it "metadata `:type => :routing` sets up routing example groups" do
    a_controller_class = Class.new
    stub_const "SomeController", a_controller_class

    group = RSpec.describe(SomeController, :type => :routing)

    expect(group).to respond_to(:routes)
    expect(group.new).to be_a(RSpec::Rails::RoutingExampleGroup)
  end

  it "metadata `:type => :view` sets up view example groups" do
    a_helper_module = Module.new
    stub_const "SomeControllerHelper", a_helper_module

    group = RSpec.describe("some_controller/action.html.erb", :type => :view)

    expect(group._default_helper).to be(a_helper_module)
    expect(group.new).to be_a(RSpec::Rails::ViewExampleGroup)
  end

  it "metadata `:type => :feature` sets up feature example groups" do
    a_rails_app = double("Rails application")
    the_rails_module = Module.new
    allow(the_rails_module).to receive(:application) { a_rails_app }
    version = ::Rails::VERSION
    stub_const "Rails", the_rails_module
    stub_const 'Rails::VERSION', version

    group = RSpec.describe("Some feature description", :type => :feature)
    example = group.new

    expect(example).to respond_to(:visit)
    expect(example).to be_a(RSpec::Rails::FeatureExampleGroup)
  end

  if defined?(ActionMailer)
    it "metadata `:type => :mailer` sets up mailer example groups" do
      a_mailer_class = Class.new
      stub_const "SomeMailer", a_mailer_class
      group = RSpec.describe(SomeMailer, :type => :mailer)
      expect(group.mailer_class).to be(a_mailer_class)
      expect(group.new).to be_a(RSpec::Rails::MailerExampleGroup)
    end
  end

  if ::Rails::VERSION::STRING > '5'
    it "has a default #file_fixture_path of 'spec/fixtures/files'" do
      expect(config.file_fixture_path).to eq("spec/fixtures/files")
    end
  end
end
