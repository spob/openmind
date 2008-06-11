require File.dirname(__FILE__) + '/../test_helper'

class WatchesTest < Test::Unit::TestCase
    fixtures :ideas, :users

  def test_list_watched_ideas 
    idea = ideas(:first_idea)
    
    # set the release_id to null since the default list behavior is to
    # exclude scheduled ideas
    idea.update_attribute(:release_id, nil)
    u = users(:allroles)
    assert_nothing_thrown {
      Idea.list_watched_ideas(1, u, {})
    }
    # add a watch
    u.watched_ideas << idea
    
    assert_equal 1, u.watched_ideas.length
    assert_equal 1, Idea.list_watched_ideas(1, u, {}).length   
  end
  
end
