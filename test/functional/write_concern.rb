require 'test_helper'
include Mongo

class WriteConcern < Test::Unit::TestCase
  context "Write concern propogation: " do
    setup do
      @con = standard_connection
      @db  = @con[MONGO_TEST_DB]
      @col = @db['test-safe']
      @col.create_index([[:a, 1]], :unique => true)
      @col.remove
    end

    #TODO: add write concern tests for remove

    should "propogate write concern options on insert" do
      @col.insert({:a => 1})

      assert_raise_error(OperationFailure, "duplicate key") do
        @col.insert({:a => 1})
      end
    end

    should "allow write concern override on insert" do
      @col.insert({:a => 1})
      @col.insert({:a => 1}, :w => 0)
    end

    should "propogate write concern option on update" do
      @col.insert({:a => 1})
      @col.insert({:a => 2})

      assert_raise_error(OperationFailure, "duplicate key") do
        @col.update({:a => 2}, {:a => 1})
      end
    end

    should "allow write concern override on update" do
      @col.insert({:a => 1})
      @col.insert({:a => 2})
      @col.update({:a => 2}, {:a => 1}, :w => 0)
    end
  end

  context "Write concern error objects" do
    setup do
      @con = standard_connection
      @db  = @con[MONGO_TEST_DB]
      @col = @db['test']
      @col.remove
      @col.insert({:a => 1})
      @col.insert({:a => 1})
      @col.insert({:a => 1})
    end

    should "return object on update" do
      response = @col.update({:a => 1}, {"$set" => {:a => 2}},
                             :multi => true)

      assert response['updatedExisting']
      assert_equal 3, response['n']
    end

    should "return object on remove" do
      response = @col.remove({})
      assert_equal 3, response['n']
    end
  end

end
