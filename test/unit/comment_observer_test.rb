require File.dirname(__FILE__) + '/../test_helper'

class CommentObserverTest < Test::Unit::TestCase
  fixtures :ideas, :comments, :users, :watches

  context "while testing comments observer" do
    setup do
      @comment = comments(:first_comment)
      assert_not_nil @comment
    end
    
    should "create periodic jobs for watched comment" do
      c = PeriodicJob.find(:all).size
      assert_nothing_thrown {
        CommentObserver.instance.after_create @comment
      }
      assert_equal c + 1, PeriodicJob.find(:all).size
    end
    
    should "not create periodic jobs for unwatched comment" do
      c = PeriodicJob.find(:all).size
      assert_nothing_thrown {
        CommentObserver.instance.after_create comments(:third_comment)
      }
      assert_equal c, PeriodicJob.find(:all).size
    end
  end
end
