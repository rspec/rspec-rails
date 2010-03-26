require 'spec_helper'

describe Rspec::Rails::TransactionalDatabaseSupport do
  class TestBed
    include Rspec::Rails::TransactionalDatabaseSupport
  end

  let(:test_bed) { TestBed.new }
  let(:connection) { stub() }

  describe "#transactional_protection_start" do
    before do
      test_bed.stub(:active_record_configured?).and_return(true)
      ::ActiveRecord::Base.stub(:connection).and_return(connection)
    end

    context 'when running with examples with transactions' do
      it "opens a new transaction" do
        test_bed.stub(:use_transactional_examples?).and_return true
        connection.should_receive(:increment_open_transactions)
        connection.should_receive(:begin_db_transaction)
        test_bed.transactional_protection_start
      end
    end

    context 'with transactionless examples' do

      it "doesn't open a transaction" do
        test_bed.stub(:use_transactional_examples?).and_return false
        connection.should_not_receive(:increment_open_transactions)
        connection.should_not_receive(:begin_db_transaction)
        test_bed.transactional_protection_start
      end
    end
  end

  describe "#transactional_protection_cleanup" do
    before do
      test_bed.stub(:active_record_configured?).and_return(true)
      connection.stub(:open_transactions).and_return(1)
      ::ActiveRecord::Base.stub(:connection).and_return(connection)
    end

    context 'when running with examples with transactions' do
      it "opens a new transaction" do
        test_bed.stub(:use_transactional_examples?).and_return(true)
        connection.should_receive(:rollback_db_transaction)
        connection.should_receive(:decrement_open_transactions)
        test_bed.transactional_protection_cleanup
      end
    end

    context 'with transactionless examples' do
      it "doesn't close an open transaction" do
        test_bed.stub(:use_transactional_examples?).and_return(false)
        connection.should_not_receive(:decrement_open_transactions)
        connection.should_not_receive(:rollback_db_transaction)
        test_bed.transactional_protection_cleanup
      end
    end
  end
end
