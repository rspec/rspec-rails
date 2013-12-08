require "spec_helper"

describe "ActiveSupport::Relation match_array matcher" do
  before { MockableModel.delete_all }

  let!(:models) { Array.new(3) { MockableModel.create } }

  if ::Rails::VERSION::STRING >= '4'
    it "verifies that the scope returns the records on the right hand side, regardless of order" do
      expect(MockableModel.all).to match_array(models.reverse)
    end

    it "fails if the scope encompasses more records than on the right hand side" do
      MockableModel.create
      expect(MockableModel.all).not_to match_array(models.reverse)
    end
  else
    it "verifies that the scope returns the records on the right hand side, regardless of order" do
      expect(MockableModel.scoped).to match_array(models.reverse)
    end

    it "fails if the scope encompasses more records than on the right hand side" do
      MockableModel.create
      expect(MockableModel.scoped).not_to match_array(models.reverse)
    end
  end

  it "fails if the scope encompasses fewer records than on the right hand side" do
    expect(MockableModel.limit(models.length - 1)).not_to match_array(models.reverse)
  end
end
