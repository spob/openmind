require File.dirname(__FILE__) + '/../test_helper'

class TaskSchedulerBatchTest < Test::Unit::TestCase
  
  should_require_attributes :run_counter
  
  should "get next counter" do
    counter = TaskSchedulerBatch.get_next_count
    counter2 = TaskSchedulerBatch.get_next_count
    assert_equal(counter + 1, counter2)
    counter3 = TaskSchedulerBatch.get_next_count
    assert_equal(counter + 2, counter3)
    
    assert_not_nil TaskSchedulerBatch.get_batch
  end
end
