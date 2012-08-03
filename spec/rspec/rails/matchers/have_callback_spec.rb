require "spec_helper"

describe "have_callback matcher" do
  include RSpec::Rails::Matchers

  context "before" do
    let(:record) do
      Class.new do
        extend ActiveModel::Callbacks
        define_model_callbacks :saving_the_day, :only => :before
        before_saving_the_day :punchline
      end.new
    end
    context "correct method" do
      context "correct callback" do
        it "passes" do
          record.should have_callback(:punchline).before(:saving_the_day)
        end
      end
      context "wrong callback" do
        it "fails" do
          record.should_not have_callback(:punchline).before(:breakfast)
        end
      end
    end
    context "wrong method" do
      it "fails" do
        record.should_not have_callback(:silence).before(:saving_the_day)
      end
    end
  end

  context "after" do
    let(:record) do
      Class.new do
        extend ActiveModel::Callbacks
        define_model_callbacks :saving_the_day, :only => :after
        after_saving_the_day :relax
      end.new
    end
    context "correct method" do
      context "correct callback" do
        it "passes" do
          record.should have_callback(:relax).after(:saving_the_day)
        end
      end
      context "wrong callback" do
        it "fails" do
          record.should_not have_callback(:relax).after(:breakfast)
        end
      end
    end
    context "wrong method" do
      it "fails" do
        record.should_not have_callback(:silence).after(:saving_the_day)
      end
    end
  end

  context "without specifying a callback kind" do
    let(:record) do
      Class.new do
        extend ActiveModel::Callbacks
        define_model_callbacks :saving_the_day, :only => :before
        before_saving_the_day :punchline
      end.new
    end
    it "raises an argument error" do
      expect { record.should have_callback(:punchline) }.to raise_error(ArgumentError)
    end
  end
end
