class ExecuteQuery < ActiveRecord::Base
  connection.execute <<-SQL
    CREATE TABLE execute_queries (
      id integer PRIMARY KEY AUTOINCREMENT
    )
  SQL
end

RSpec.describe "SQL Query matchers" do
  context "execute_queries" do
    context "without options" do
      it "passes" do
        expect {
          expect { ExecuteQuery.first }.to execute_queries(1)
        }.to_not raise_error
      end

      it "passes for multiple queries" do
        expect {
          expect { 3.times { ExecuteQuery.first } }.to execute_queries(3)
        }.to_not raise_error
      end

      it "fails" do
        expect {
          expect { ExecuteQuery.first }.to execute_queries(2)
        }.to raise_error("expected block to execute 2 SQL queries, got 1")
      end
    end

    context "including_schema" do
      it "passes" do
        expect {
          expect {
            ExecuteQuery.columns
            ExecuteQuery.reset_column_information
          }.to execute_queries(2).including_schema
        }.to_not raise_error
      end

      it "fails" do
        expect {
          expect {
            ExecuteQuery.columns
            ExecuteQuery.reset_column_information
          }.to execute_queries(1).including_schema
        }.to raise_error("expected block to execute 1 SQL query (including schema operations), got 2")
      end
    end

    context "matching" do
      it "passes" do
        expect {
          expect { ExecuteQuery.first }.to execute_queries(1).matching(/SELECT/)
        }.to_not raise_error
      end

      it "fails" do
        expect {
          expect { ExecuteQuery.first }.to execute_queries(1).matching(/INSERT/)
        }.to raise_error("expected block to execute 1 SQL query matching /INSERT/, got 0")
      end
    end
  end
end
