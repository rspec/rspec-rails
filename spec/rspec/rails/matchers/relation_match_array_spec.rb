require "spec_helper"

describe "ActiveSupport::Relation =~ matcher" do
  before { MockableModel.delete_all }
  
  let!(:models) { Array.new(3) { MockableModel.create } }

  it "verifies that the scope returns the records on the right hand side, regardless of order" do
    MockableModel.scoped.should =~ models.reverse
  end

  it "fails if the scope encompasses more records than on the right hand side" do
    MockableModel.create
    MockableModel.scoped.should_not =~ models.reverse
  end

  it "fails if the scope encompasses fewer records than on the right hand side" do
    MockableModel.limit(models.length - 1).should_not =~ models.reverse
  end
end
