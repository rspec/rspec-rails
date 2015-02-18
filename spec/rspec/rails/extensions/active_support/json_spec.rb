require "spec_helper"
require "active_support"
if ::Rails::VERSION::STRING > '4.1'
  require "active_support/core_ext/object/json"
else
  require "active_support/core_ext/object/to_json"
end
require "rspec/rails/extensions/active_support/json"

RSpec.describe "Patch mocks to work with Active Support's json patches" do

  shared_examples "verifies the patch arguments" do
    it "verifies arguments" do
      allow(subject).to receive(patch)
      expect { subject.send(patch, :too, :many) }.to raise_error(ArgumentError)
    end
  end

  shared_examples "intercepts Active Support's patch" do |message, opts|
    opts ||= {}
    context "intercepts Active Support's ##{message}" do
      defaults = { :to_json => "null", :as_json => nil }

      let(:patch) { message }
      let(:default) { defaults[patch] }

      it "responds to the message" do
        expect(subject).to respond_to(patch)
      end

      it "defines a sane default implementation" do
        expect(subject.send(patch)).to eq(default)
      end

      it "records the message being received" do
        subject.send(patch)
        expect(subject).to have_received(patch)
      end

      it "doesn't interfere with a stubbed response" do
        allow(subject).to receive(patch).and_return(:stubbed)
        expect(subject.send(patch)).to be(:stubbed)
      end

      include_examples "verifies the patch arguments" if opts[:verified]
    end
  end

  shared_examples "ignores Active Support's patch" do |message, opts|
    opts ||= {}
    context "ignores Active Support's ##{message}" do
      let(:patch) { message }

      it "raises errors when messages not allowed or expected are received" do
        expect { subject.send(patch) }.to raise_error(
          /received unexpected message :#{patch} with \(no args\)/
        )
      end

      it "does not respond to the message when not allowed or expected" do
        expect(subject).not_to respond_to(patch)
      end

      it "does respond to the message when allowed or expected" do
        allow(subject).to receive(patch)
        expect(subject).to respond_to(patch)
      end

      it "returns a stubbed value" do
        allow(subject).to receive(patch).and_return(:stubbed)
        expect(subject.send(patch)).to be(:stubbed)
      end

      it "captures a set expectation" do
        expect(subject).to receive(patch)
        subject.send(patch)
      end

      include_examples "verifies the patch arguments" if opts[:verified]
    end
  end

  context "using a `spy`" do
    subject(:a_spy) { spy }

    include_examples "intercepts Active Support's patch", :to_json
    include_examples "intercepts Active Support's patch", :as_json
  end

  context "using an `instance_spy`" do
    subject(:the_spy) { instance_spy(String) }

    include_examples "intercepts Active Support's patch", :to_json, :verified => true
    include_examples "intercepts Active Support's patch", :as_json, :verified => true
  end

  context "using a `class_spy`" do
    subject(:the_spy) { class_spy(String) }

    include_examples "intercepts Active Support's patch", :to_json, :verified => true
    include_examples "intercepts Active Support's patch", :as_json, :verified => true
  end

  context "using an `object_spy`" do
    subject(:the_spy) { object_spy('test') }

    include_examples "intercepts Active Support's patch", :to_json
    include_examples "intercepts Active Support's patch", :as_json
  end

  context "using a `double`" do
    subject(:a_double) { double }

    include_examples "ignores Active Support's patch", :to_json
    include_examples "ignores Active Support's patch", :as_json
  end

  context "using an `instance_double`" do
    subject(:the_double) { instance_double(String) }

    include_examples "ignores Active Support's patch", :to_json, :verified => true
    include_examples "ignores Active Support's patch", :as_json, :verified => true
  end

  context "using a `class_double`" do
    subject(:the_double) { class_double(String) }

    include_examples "ignores Active Support's patch", :to_json, :verified => true
    include_examples "ignores Active Support's patch", :as_json, :verified => true
  end

  context "using an `object_double`" do
    subject(:the_double) { object_double('test') }

    include_examples "ignores Active Support's patch", :to_json
    include_examples "ignores Active Support's patch", :as_json
  end

  it "doesn't interfere with a partial mock's native representation" do
    obj = { :foo => "a test", :bar => 123 }
    allow(obj).to receive(:equal?).and_return(false)
    expect(obj.to_json).to eq("{\"foo\":\"a test\",\"bar\":123}")
    expect(obj.as_json).to eq({ "foo" => "a test", "bar" => 123 })
  end

  context "with BasicObject" do
    if defined?(::BasicObject)
      before(:example) do
        basic_object = Class.new do
          undef :as_json
          undef :to_json
        end
        stub_const("BasicObject", basic_object)
      end
    else
      # Sanity check to ensure Rails didn't change this on us
      before(:context) do
        expect(BasicObject).not_to respond_to(:as_json)
        expect(BasicObject).not_to respond_to(:to_json)
      end
    end

    basic_object_not_implemented_to_json =
      /BasicObject( class)? does not implement.+to_json/
    basic_object_not_implemented_as_json =
      /BasicObject( class)? does not implement.+as_json/

    it "doesn't pollute spies" do
      expect(instance_spy(BasicObject)).not_to respond_to(:to_json)
      expect { instance_spy(BasicObject).to_json }.to raise_error(
        basic_object_not_implemented_to_json
      )
      expect { instance_spy(BasicObject, :to_json => 'test') }.to raise_error(
        basic_object_not_implemented_to_json
      )

      expect(instance_spy(BasicObject)).not_to respond_to(:as_json)
      expect { instance_spy(BasicObject).as_json }.to raise_error(
        basic_object_not_implemented_as_json
      )
      expect { instance_spy(BasicObject, :as_json => 'test') }.to raise_error(
        basic_object_not_implemented_as_json
      )
    end

    it "doesn't pollute doubles" do
      expect { instance_double(BasicObject, :to_json => 'test') }.to raise_error(
        basic_object_not_implemented_to_json
      )
      expect { instance_double(BasicObject, :as_json => 'test') }.to raise_error(
        basic_object_not_implemented_as_json
      )
    end
  end

end
