require "spec_helper"

describe "be_new_record" do
  include RSpec::Rails::Matchers

  context "un-persisted record" do
    let(:record) { double('record', :persisted? => false) }

    it "passes" do
      record.should be_new_record
    end

    it "fails with custom failure message" do
      expect {
        expect(record).not_to be_new_record
      }.to raise_exception(/expected .* to be persisted, but was a new record/)
    end
  end

  context "persisted record" do
    let(:record) { double('record', :persisted? => true) }

    it "fails" do
      record.should_not be_new_record
    end

    it "fails with custom failure message" do
      expect {
        expect(record).to be_new_record
      }.to raise_exception(/expected .* to be a new record, but was persisted/)
    end
  end
end
