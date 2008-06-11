require File.dirname(__FILE__) + '/../test_helper'

class VoteTest < Test::Unit::TestCase
  fixtures :votes

  def test_fetch
    vote = Vote.find(:first)
    assert_not_nil vote
  end

  def test_invalid_with_empty_attributes
    vote = Vote.new
    assert  !vote.valid?
    assert  vote.errors.invalid?(:user_id)
    assert  vote.errors.invalid?(:allocation_id)
    assert  vote.errors.invalid?(:idea_id)
  end
  
  def test_should_create_vote
    v = Vote.create(
      :user_id => votes(:first_vote).user_id,
      :allocation_id => votes(:first_vote).allocation_id,
      :idea_id => votes(:first_vote).idea_id,
      :created_at  => votes(:first_vote).created_at )
    assert v.valid?
  end

end