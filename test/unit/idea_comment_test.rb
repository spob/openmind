require File.dirname(__FILE__) + '/../test_helper'

class IdeaCommentTest < Test::Unit::TestCase
  fixtures :comments, :ideas, :users, :topics
  
  should_belong_to :idea
  should_require_attributes :idea_id
  
  context "testing can edit" do
    should "allow edit" do
      assert comments(:first_comment).can_edit?(users(:bob), true)
    end
    
    should "not allow edit" do
      assert !comments(:first_comment).can_edit?(users(:bob), false)
      assert !comments(:first_comment).can_edit?(users(:bob))
    end
  end
end