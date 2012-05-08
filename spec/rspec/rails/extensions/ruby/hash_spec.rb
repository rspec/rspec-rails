require 'spec_helper'

module RSpec::Rails::Ruby
  describe "Hash" do
    before :each  do 
      @hash = {:name => "nobody", :age => 0}
      @hash.instance_eval{extend Hash}
    end

    it 'should return the first element' do
      @hash.keep_first!
      @hash.should be == {:name => "nobody"}
    end

    it 'should return the key of the first element' do
      @hash.key.should be == :name
    end

    it 'should return the value of the first element' do
      @hash.value.should be == "nobody"
    end
  end
end
