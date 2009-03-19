# == Schema Information
# Schema version: 20081021172636
#
# Table name: comments
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  idea_id      :integer(4)
#  body         :text
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  lock_version :integer(4)      default(0)
#  type         :string(255)     not null
#  topic_id     :integer(4)
#  textiled     :boolean(1)      not null
#
require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase 
  fixtures :comments, :ideas, :users, :topics
  
  should_belong_to :user
  
  should_require_attributes :user_id, :body
  
  def test_fetch
    comment = IdeaComment.find(:first)
    assert_not_nil comment
  end  
  
  def test_invalid_with_empty_attributes
    comment = IdeaComment.new
    assert  !comment.valid?
    assert comment.errors.invalid?(:user_id)
    assert comment.errors.invalid?(:idea_id)
    assert comment.errors.invalid?(:body)
  end

  def test_should_create_comment
    comment = IdeaComment.new(
      :user_id => comments(:first_comment).user_id,
      :idea_id=>comments(:first_comment).idea_id,
      :body=>comments(:first_comment).body)
    assert comment.valid?
    
    comment = TopicComment.new(
      :user_id => comments(:first_comment).user_id,
      :topic_id=>comments(:first_comment).idea_id,
      :body=>comments(:first_comment).body)
    assert comment.valid?
  end  
  
  def test_last_comment
    user = users(:allocation_calculation_test)
    idea = ideas(:no_comments_idea)
    comment1 = IdeaComment.new(:user_id => user.id, :body => "blah1")
    comment2 = IdeaComment.new(:user_id => user.id, :body => "blah2")
    idea.comments << comment1
    idea.comments << comment2
    idea.save
    idea = Idea.find(idea.id)
    assert !comment1.can_edit?(user)
    assert comment1.can_edit?(user, true)
    assert comment2.can_edit?(user)
  end
  
  should "allow edit" do
    assert Comment.new.can_edit?(users(:quentin))
  end
end