require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < Test::Unit::TestCase
  fixtures :users, :topics, :forum_mediators, :forums

  # Replace this with your real tests.
  def test_invalid_with_empty_attributes
    forum = Forum.new(:name => "", :description => "")
    assert !forum.valid?
    
    assert forum.errors.invalid?(:name)
    assert_equal "can't be blank", 
      forum.errors.on(:name)
    
    assert forum.errors.invalid?(:description)
    assert_equal "can't be blank", 
      forum.errors.on(:description)
  end
  
  def test_name_invalid_too_long
    forum = Forum.new(:name => "0123456789012345678901234567890123456789012345678901")
    assert !forum.valid?
    assert_equal "is too long (maximum is 50 characters)", 
      forum.errors.on(:name)
  end
  
  def test_description_invalid_too_long
    forum = Forum.new(:description => "0123456789012345678901234567890123456789012345678900123456789012345678901234567890123456789012345678900123456789012345678901234567890123456789012345678901")
    assert !forum.valid?
    assert_equal "is too long (maximum is 150 characters)", 
      forum.errors.on(:description)
  end
  
  def test_valid_with_attributes
    forum = Forum.new(:name => "bugs2", :description => "wassup")
    assert forum.valid?
  end
  
  def test_list
    assert Forum.list(1, 10).size > 0
  end
  
  def test_mediators
    forum = Forum.find forums(:bugs_forum).id
    assert_equal 1, forum.topics.size
    assert !forum.can_delete?
    assert_equal 1, forum.mediators.count
  end
end
