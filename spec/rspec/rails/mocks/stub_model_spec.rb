require 'spec_helper'

describe "stub_model" do

  shared_examples_for "stub model" do
    describe "with a block" do
      it "yields the model" do
        model = stub_model(model_class) do |block_arg|
          @block_arg = block_arg
        end
        expect(model).to be(@block_arg)
      end
    end

    describe "#persisted?" do
      context "default" do
        it "returns true" do
          model = stub_model(model_class)
          expect(model).to be_persisted
        end
      end

      context "with as_new_record" do
        it "returns false" do
          model = stub_model(model_class).as_new_record
          expect(model).not_to be_persisted
        end
      end
    end

    it "increments the value returned by to_param" do
      first = stub_model(model_class)
      second = stub_model(model_class)
      expect(second.to_param.to_i).to eq(first.to_param.to_i + 1)
    end

    describe "#blank?" do
      it "is false" do
        expect(stub_model(model_class)).not_to be_blank
      end
    end
  end

  context "with ActiveModel (not ActiveRecord)" do
    it_behaves_like "stub model" do
      def model_class
        NonActiveRecordModel
      end
    end
  end

  context "with an ActiveRecord model" do
    let(:model_class) { MockableModel }

    it_behaves_like "stub model"

    describe "#new_record?" do
      context "default" do
        it "returns false" do
          model = stub_model(model_class)
          expect(model.new_record?).to be_falsey
        end
      end

      context "with as_new_record" do
        it "returns true" do
          model = stub_model(model_class).as_new_record
          expect(model.new_record?).to be_truthy
        end
      end
    end

    describe "defaults" do
      it "has an id" do
        expect(stub_model(MockableModel).id).to be > 0
      end

      it "says it is not a new record" do
        expect(stub_model(MockableModel)).not_to be_new_record
      end
    end

    describe "#as_new_record" do
      it "has a nil id" do
        expect(stub_model(MockableModel).as_new_record.id).to be(nil)
      end
    end

    it "raises when hitting the db" do
      expect do
        stub_model(MockableModel).connection
      end.to raise_error(RSpec::Rails::IllegalDataAccessException, /stubbed models are not allowed to access the database/)
    end

    it "increments the id" do
      first = stub_model(model_class)
      second = stub_model(model_class)
      expect(second.id).to eq(first.id + 1)
    end

    it "accepts a stub id" do
      expect(stub_model(MockableModel, :id => 37).id).to eq(37)
    end

    it "says it is a new record when id is set to nil" do
      expect(stub_model(MockableModel, :id => nil)).to be_new_record
    end

    it "accepts a stub for save" do
      expect(stub_model(MockableModel, :save => false).save).to be(false)
    end

    describe "alternate primary key" do
      it "has the correct primary_key name" do
        expect(stub_model(AlternatePrimaryKeyModel).class.primary_key.to_s).to eq('my_id')
      end

      it "has a primary_key" do
        expect(stub_model(AlternatePrimaryKeyModel).my_id).to be > 0
      end

      it "says it is not a new record" do
        stub_model(AlternatePrimaryKeyModel) do |m|
          expect(m).not_to be_new_record
        end
      end

      it "says it is a new record if primary_key is nil" do
        expect(stub_model(AlternatePrimaryKeyModel, :my_id => nil)).to be_new_record
      end

      it "accepts a stub for the primary_key" do
        expect(stub_model(AlternatePrimaryKeyModel, :my_id => 5).my_id).to eq(5)
      end
    end

    describe "as association" do
      before(:each) do
        @real = AssociatedModel.create!
        @stub_model = stub_model(MockableModel)
        @real.mockable_model = @stub_model
      end

      it "passes associated_model == mock" do
        expect(@stub_model).to eq(@real.mockable_model)
      end

      it "passes mock == associated_model" do
        expect(@real.mockable_model).to eq(@stub_model)
      end
    end

  end
end
