require "spec_helper"

module RSpec::Rails
  describe ViewExampleGroup do
    it { is_expected.to be_included_in_files_in('./spec/views/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\views\\') }

    it "adds :type => :view to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include ViewExampleGroup
      end
      expect(group.metadata[:type]).to eq(:view)
    end

    describe 'automatic inclusion of helpers' do
      module ::ThingsHelper; end
      module ::Namespaced; module ThingsHelper; end; end

      it 'includes the helper with the same name' do
        group = RSpec::Core::ExampleGroup.describe 'things/show.html.erb'
        expect(group).to receive(:helper).with(ThingsHelper)
        group.class_eval do
          include ViewExampleGroup
        end
      end

      it 'includes the namespaced helper with the same name' do
        group = RSpec::Core::ExampleGroup.describe 'namespaced/things/show.html.erb'
        expect(group).to receive(:helper).with(Namespaced::ThingsHelper)
        group.class_eval do
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
          group.class_eval do
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
          if @application_helper
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

    describe "#render" do
      let(:view_spec) do
        Class.new do
          module Local
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
          include Local
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
            expect(view_spec.received.first).to eq([{:template => "widgets/new", :locales=>['en'], :formats=>['html'], :handlers=>['erb']}, {}, nil])
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
  end
end
