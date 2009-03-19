require File.dirname(__FILE__) + '/../test_helper'

class AllocationObserverTest < ActiveSupport::TestCase
  fixtures :enterprises, :allocations, :users

  context "while testing allocation observer" do
    setup do
      @allocationU = allocations(:user_allocation)
      @allocationE = allocations(:enterprise_allocation)
    end
    
    should "create periodic jobs for user allocation" do
      c = PeriodicJob.find(:all).size
      assert_nothing_thrown {
        AllocationObserver.instance.after_create @allocationU
      }
      assert_equal c + 1, PeriodicJob.find(:all).size
    end
    
    should "create periodic jobs for enteprise allocation" do
      c = PeriodicJob.find(:all).size
      assert_nothing_thrown {
        AllocationObserver.instance.after_create @allocationE
      }
      assert_equal c + 1, PeriodicJob.find(:all).size
    end
  end
end
