require File.dirname(__FILE__) + '/../test_helper'

class TaskSchedulerBatchTest < Test::Unit::TestCase
  
  def test_get_next_counter
    counter = TaskSchedulerBatch.get_next_count
    counter2 = TaskSchedulerBatch.get_next_count
    assert_equal(counter + 1, counter2)
    counter3 = TaskSchedulerBatch.get_next_count
    assert_equal(counter + 2, counter3)
  end
end
