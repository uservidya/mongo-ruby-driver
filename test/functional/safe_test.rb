require 'test_helper'
include Mongo

class SafeTest < Test::Unit::TestCase
  context "Safe mode propogation: " do
    setup do
      @client     = standard_connection({:safe => {:w => 1}}, true)
      @db         = @client[MONGO_TEST_DB]
      @collection = @db['test-safe']
      @collection.create_index([[:a, 1]], :unique => true)
      @collection.remove
    end

    should "propogate safe option on insert" do
      @collection.insert({:a => 1})

      assert_raise_error(OperationFailure, "duplicate key") do
        @collection.insert({:a => 1})
      end
    end

    should "allow safe override on insert" do
      @collection.insert({:a => 1})
      @collection.insert({:a => 1}, :safe => false)
    end

    should "propogate safe option on update" do
      @collection.insert({:a => 1})
      @collection.insert({:a => 2})

      assert_raise_error(OperationFailure, "duplicate key") do
        @collection.update({:a => 2}, {:a => 1})
      end
    end

    should "allow safe override on update" do
      @collection.insert({:a => 1})
      @collection.insert({:a => 2})
      @collection.update({:a => 2}, {:a => 1}, :safe => false)
    end
  end

  context "Safe error objects" do
    setup do
      @client     = standard_connection({}, true)
      @db         = @client[MONGO_TEST_DB]
      @collection = @db['test']
      @collection.remove
      @collection.insert({:a => 1})
      @collection.insert({:a => 1})
      @collection.insert({:a => 1})
    end

    should "return object on update" do
      response = @collection.update({:a => 1}, {"$set" => {:a => 2}},
                             :multi => true, :safe => true)

      assert response['updatedExisting']
      assert_equal 3, response['n']
    end

    should "return object on remove" do
      response = @collection.remove({}, :safe => true)
      assert_equal 3, response['n']
    end
  end

end