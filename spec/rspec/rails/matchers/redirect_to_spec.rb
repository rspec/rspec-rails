require "spec_helper"

describe "be_a_new matcher" do
  context "new record" do
    let(:record) do
      Class.new do
        def new_record?; true; end
      end.new
    end
    context "right class" do
      it "passes" do
        record.should be_a_new(record.class)
      end
    end
    context "wrong class" do
      it "fails" do
        record.should_not be_a_new(String)
      end
    end
  end

  context "existing record" do
    let(:record) do
      Class.new do
        def new_record?; false; end
      end.new
    end
    context "right class" do
      it "fails" do
        record.should_not be_a_new(record.class)
      end
    end
    context "wrong class" do
      it "fails" do
        record.should_not be_a_new(String)
      end
    end
  end
end
