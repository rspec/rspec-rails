require 'spec_helper'

describe Rspec::Rails::TransactionalDatabaseSupport do

  let(:connection) { double('connection', :open_transactions => 1) }
  let(:test_bed) do
    Class.new do
      include Rspec::Rails::TransactionalDatabaseSupport
      def active_record_configured?; true; end
    end.new
  end

  before { ::ActiveRecord::Base.stub(:connection) { connection } }

  describe "#setup_transactional_examples" do
    context 'when running with examples with transactions' do
      it "opens a new transaction" do
        test_bed.stub(:use_transactional_examples?) { true }
        connection.should_receive(:increment_open_transactions)
        connection.should_receive(:begin_db_transaction)
        test_bed.setup_transactional_examples
      end
    end

    context 'with transactionless examples' do
      it "doesn't open a transaction" do
        test_bed.stub(:use_transactional_examples?) { false }
        connection.should_not_receive(:increment_open_transactions)
        connection.should_not_receive(:begin_db_transaction)
        test_bed.setup_transactional_examples
      end
    end
  end

  describe "#teardown_transactional_examples" do
    context 'when running with examples with transactions' do
      it "opens a new transaction" do
        test_bed.stub(:use_transactional_examples?) { true }
        connection.should_receive(:rollback_db_transaction)
        connection.should_receive(:decrement_open_transactions)
        test_bed.teardown_transactional_examples
      end
    end

    context 'with transactionless examples' do
      it "doesn't close an open transaction" do
        test_bed.stub(:use_transactional_examples?) { false }
        connection.should_not_receive(:decrement_open_transactions)
        connection.should_not_receive(:rollback_db_transaction)
        test_bed.teardown_transactional_examples
      end
    end
  end
end
