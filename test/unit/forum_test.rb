require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < Test::Unit::TestCase
  fixtures :forums, :forum_mediators

  # Replace this with your real tests.
  def test_invalid_with_empty_attributes
    forum = Forum.new()
    assert !forum.valid?
    assert forum.errors.invalid?(:name)
  end
  
  def test_invalid_too_long
    forum = Forum.new(:name => "0123456789012345678901234567890123456789012345678901")
    assert !forum.valid?
    assert_equal "is too long (maximum is 50 characters)", 
      forum.errors.on(:name)
  end
  
  def test_valid_with_attributes
    forum = Forum.new(:name => "bugs")
    assert forum.valid?
  end
  
  def test_list
    assert Forum.list(1, 10).size > 0
  end
  
  def test_mediators
    forum = Forum.find forums(:bugs_forum).id
    assert forum.mediators.count == 1
  end
end
