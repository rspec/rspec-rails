require "spec_helper"

describe "standard Rails dynamic matchers in verifying doubles" do
  context "store_accessor" do
    before do
      class Book
        include ActiveRecord::Store
        store_accessor :data
      end
    end

    it "should be ok to use it as a verifying double" do
      expect(Book.new).not_to respond_to(:data)
      expect {
        instance_double('Book', :data => {:whatever => :something})
      }.not_to raise_exception
    end
  end
end
