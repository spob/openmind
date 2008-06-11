require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments, :ideas, :users
  
  def test_fetch
    comment = Comment.find(:first)
    assert_not_nil comment
  end  
  
  def test_invalid_with_empty_attributes
    comment = Comment.new
    assert  !comment.valid?
    assert comment.errors.invalid?(:user_id)
    assert comment.errors.invalid?(:idea_id)
    assert comment.errors.invalid?(:body)
  end

  def test_should_create_comment
    comment = Comment.new(
      :user_id => comments(:first_comment).user_id,
      :idea_id=>comments(:first_comment).idea_id,
      :body=>comments(:first_comment).body)
    assert comment.valid?
  end  
  
  def test_last_comment
    user = users(:allocation_calculation_test)
    idea = ideas(:no_comments_idea)
    comment1 = Comment.new(:user_id => user.id, :body => "blah1")
    comment2 = Comment.new(:user_id => user.id, :body => "blah2")
    idea.comments << comment1
    idea.comments << comment2
    idea.save
    idea = Idea.find(idea.id)
    assert !comment1.can_edit?(user)
    assert comment1.can_edit?(user, true)
    assert comment2.can_edit?(user)
  end
end