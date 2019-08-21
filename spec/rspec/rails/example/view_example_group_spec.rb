require "spec_helper"

module RSpec::Rails
  describe ViewExampleGroup do
    it_behaves_like "an rspec-rails example group mixin", :view,
      './spec/views/', '.\\spec\\views\\'

    describe 'automatic inclusion of helpers' do
      module ::ThingsHelper; end
      module ::Namespaced; module ThingsHelper; end; end

      it 'includes the helper with the same name' do
        group = RSpec::Core::ExampleGroup.describe 'things/show.html.erb'
        expect(group).to receive(:helper).with(ThingsHelper)
        group.class_exec do
          include ViewExampleGroup
        end
      end

      it 'includes the namespaced helper with the same name' do
        group = RSpec::Core::ExampleGroup.describe 'namespaced/things/show.html.erb'
        expect(group).to receive(:helper).with(Namespaced::ThingsHelper)
        group.class_exec do
          include ViewExampleGroup
        end
      end

      it 'operates normally when no helper with the same name exists' do
        raise 'unexpected constant found' if Object.const_defined?('ClocksHelper')
        expect {
          RSpec::Core::ExampleGroup.describe 'clocks/show.html.erb' do
            include ViewExampleGroup
          end
        }.not_to raise_error
      end

      it 'operates normally when the view has no path and there is a Helper class defined' do
        class ::Helper; end
        expect {
          RSpec::Core::ExampleGroup.describe 'show.html.erb' do
            include ViewExampleGroup
          end
        }.not_to raise_error
      end

      context 'application helper exists' do
        before do
          if !Object.const_defined? 'ApplicationHelper'
            module ::ApplicationHelper; end
            @application_helper_defined = true
          end
        end

        after do
          if @application_helper_defined
            Object.__send__ :remove_const, 'ApplicationHelper'
          end
        end

        it 'includes the application helper' do
          group = RSpec::Core::Example.describe 'bars/new.html.erb'
          expect(group).to receive(:helper).with(ApplicationHelper)
          group.class_exec do
            include ViewExampleGroup
          end
        end
      end

      context 'no application helper exists' do
        before do
          if Object.const_defined? 'ApplicationHelper'
            @application_helper = ApplicationHelper
            Object.__send__ :remove_const, 'ApplicationHelper'
          end
        end

        after do
          if defined?(@application_helper)
            ApplicationHelper = @application_helper
          end
        end

        it 'operates normally' do
          expect {
            RSpec::Core::ExampleGroup.describe 'foos/edit.html.erb' do
              include ViewExampleGroup
            end
          }.not_to raise_error
        end
      end
    end

    describe "routes helpers collides with asset helpers" do
      let(:view_spec) do
        Class.new do
          include ActionView::Helpers::AssetTagHelper
          include ViewExampleGroup::ExampleMethods
        end.new
      end

      let(:test_routes) do
        ActionDispatch::Routing::RouteSet.new.tap do |routes|
          routes.draw { resources :images }
        end
      end

      it "uses routes helpers" do
        allow(::Rails.application).to receive(:routes).and_return(test_routes)
        expect(view_spec.image_path(double(:to_param => "42"))).
          to eq "/images/42"
      end
    end

    describe "#render" do
      let(:view_spec) do
        Class.new do
          local = Module.new do
            def received
              @received ||= []
            end
            def render(options={}, local_assigns={}, &block)
              received << [options, local_assigns, block]
            end
            def _assigns
              {}
            end
          end
          include local
          include ViewExampleGroup::ExampleMethods
        end.new
      end

      context "given no input" do
        it "sends render(:template => (described file)) to the view" do
          allow(view_spec).to receive(:_default_file_to_render) { "widgets/new" }
          view_spec.render
          expect(view_spec.received.first).to eq([{:template => "widgets/new"},{}, nil])
        end

        it "converts the filename components into render options" do
          allow(view_spec).to receive(:_default_file_to_render) { "widgets/new.en.html.erb" }
          view_spec.render

          if ::Rails::VERSION::STRING >= '3.2'
            expect(view_spec.received.first).to eq([{:template => "widgets/new", :locales=>['en'], :formats=>[:html], :handlers=>['erb']}, {}, nil])
          else
            expect(view_spec.received.first).to eq([{:template => "widgets/new.en.html.erb"}, {}, nil])
          end
        end
      end

      context "given a string" do
        it "sends string as the first arg to render" do
          view_spec.render('arbitrary/path')
          expect(view_spec.received.first).to eq(["arbitrary/path", {}, nil])
        end
      end

      context "given a hash" do
        it "sends the hash as the first arg to render" do
          view_spec.render(:foo => 'bar')
          expect(view_spec.received.first).to eq([{:foo => "bar"}, {}, nil])
        end
      end
    end

    describe '#params' do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::ExampleMethods
          def controller
            @controller ||= Object.new
          end
        end.new
      end

      it 'delegates to the controller' do
        expect(view_spec.controller).to receive(:params).and_return({})
        view_spec.params[:foo] = 1
      end
    end

    describe "#_controller_path" do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::ExampleMethods
        end.new
      end
      context "with a common _default_file_to_render" do
        it "it returns the directory" do
          allow(view_spec).to receive(:_default_file_to_render).
            and_return("things/new.html.erb")
          expect(view_spec.__send__(:_controller_path)).
            to eq("things")
        end
      end

      context "with a nested _default_file_to_render" do
        it "it returns the directory path" do
          allow(view_spec).to receive(:_default_file_to_render).
            and_return("admin/things/new.html.erb")
          expect(view_spec.__send__(:_controller_path)).
            to eq("admin/things")
        end
      end
    end

    describe "#view" do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::ExampleMethods
        end.new
      end

      it "delegates to _view" do
        view = double("view")
        allow(view_spec).to receive(:_view) { view }
        expect(view_spec.view).to eq(view)
      end

      it 'is accessible to hooks' do
        with_isolated_config do
          run_count = 0
          RSpec.configuration.before(:each, :type => :view) do
            allow(view).to receive(:a_stubbed_helper) { :value }
            run_count += 1
          end
          group = RSpec::Core::ExampleGroup.describe 'a view', :type => :view do
            specify { true }
          end
          group.run NullObject.new
          expect(run_count).to eq 1
        end
      end
    end

    describe "#template" do
      let(:view_spec) do
        Class.new do
          include ViewExampleGroup::ExampleMethods
          def _view; end
        end.new
      end

      before { allow(RSpec).to receive(:deprecate) }

      it "is deprecated" do
        expect(RSpec).to receive(:deprecate)
        view_spec.template
      end

      it "delegates to #view" do
        expect(view_spec).to receive(:view)
        view_spec.template
      end
    end

    describe '#stub_template' do
      let(:view_spec_group) do
        Class.new do
          include ViewExampleGroup::ExampleMethods
          def _view
            @_view ||= Struct.new(:view_paths).new(['some-path'])
          end
        end
      end

      it 'prepends an ActionView::FixtureResolver to the view path' do
        view_spec = view_spec_group.new
        view_spec.stub_template('some_path/some_template' => 'stubbed-contents')

        result = view_spec.view.view_paths.first

        expect(result).to be_instance_of(ActionView::FixtureResolver)
        expect(result.data).to eq('some_path/some_template' => 'stubbed-contents')
      end

      it 'caches FixtureResolver instances between example groups' do
        view_spec_one = view_spec_group.new
        view_spec_two = view_spec_group.new

        view_spec_one.stub_template('some_path/some_template' => 'stubbed-contents')
        view_spec_two.stub_template('some_path/some_template' => 'stubbed-contents')

        expect(view_spec_one.view.view_paths.first).to eq(view_spec_two.view.view_paths.first)
      end
    end
  end
end
