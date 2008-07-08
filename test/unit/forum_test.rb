require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < Test::Unit::TestCase
  fixtures :forums

  # Replace this with your real tests.
  def test_invalid_with_empty_attributes
    forum = Forum.new()
    assert !forum.valid?
    assert forum.errors.invalid?(:name)
  end
end
