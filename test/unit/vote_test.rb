# == Schema Information
# Schema version: 20081021172636
#
# Table name: votes
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      not null
#  allocation_id :integer(4)
#  idea_id       :integer(4)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  lock_version  :integer(4)      default(0)
#  comments      :text
#
require File.dirname(__FILE__) + '/../test_helper'

class VoteTest < ActiveSupport::TestCase 
  fixtures :votes, :allocations, :ideas, :users, :enterprises

  should_belong_to :idea
  should_belong_to :allocation
  should_belong_to :user
  should_require_attributes :user_id, :allocation_id, :idea_id
  
  def test_fetch
    vote = Vote.find(:first)
    assert_not_nil vote
  end
  
  context "testing list" do
    should "retrieve values from list" do
      assert !Vote.list(1, 10).empty?
      assert !Vote.list(1, 10, enterprises(:active_enterprise)).empty?
      assert !Vote.list(1, 10, nil, users(:allroles)).empty?
      assert !Vote.list(1, 10, enterprises(:active_enterprise), users(:allroles)).empty?
    end
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

  should "allow delete" do
    assert votes(:first_vote).can_delete?
  end
end