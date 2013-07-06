Feature: records

  Scenario: asserting number of records
    Given a file named "spec/models/widget_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Widget do
        it "has no widgets in the database" do
          expect(Widget).to have(:no).records
          expect(Widget).to have(0).records
        end

        it "has one record" do
          Widget.create!(:name => "Cog")
          expect(Widget).to have(1).record
        end

        it "counts only records that match a query" do
          Widget.create!(:name => "Cog")
          expect(Widget.where(:name => "Cog")).to have(1).record
          expect(Widget.where(:name => "Wheel")).to have(0).records
        end
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass
