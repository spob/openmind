require File.dirname(__FILE__) + '/../test_helper'

class UserIdeaReadTest < Test::Unit::TestCase
  fixtures :user_idea_reads, :users, :ideas
  
  def test_create
    i = UserIdeaRead.create(:user_id => users(:active_user_inactive_enterprise).id, 
      :idea_id => ideas(:first_idea).id, :last_read => Time.zone.now)
    assert i.valid?
  end
end
