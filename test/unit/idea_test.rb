require File.dirname(__FILE__) + '/../test_helper'
require 'exceptions/vote_exception'

class IdeaTest < Test::Unit::TestCase
  fixtures :ideas, :votes, :users, :products, :releases, :comments, :idea_change_logs
  
  should_have_many :change_logs

  def test_fetch
    idea = Idea.find(:first)
    assert_not_nil idea
  end

  def test_invalid_with_empty_attributes
    idea = Idea.new
    assert !idea.valid?
    assert idea.errors.invalid?(:user_id)
    assert idea.errors.invalid?(:product_id)
    assert idea.errors.invalid?(:title)
    assert idea.errors.invalid?(:description)
  end
  
  def test_can_delete
    idea = ideas(:first_idea)
    # should fail...has votes associated to it
    assert !idea.can_delete?
    
    idea.votes.delete_all
    # still has comments... should not be able to delete
    assert !idea.can_delete?
    
    idea.comments.delete_all
    # now should be able to delete
    assert idea.can_delete?
  end
  
  context "testing change notifications" do
    should "send notification" do
      assert_nil idea_change_logs(:first_idea_update).processed_at
      assert !ideas(:first_idea).unprocessed_change_logs.empty?
      assert_nothing_thrown {
        Idea.send_change_notifications(ideas(:first_idea).id)
      }
      assert_not_nil IdeaChangeLog.find(idea_change_logs(:first_idea_update).id).processed_at
    end
  end
  
  should "format as redcloth" do
    assert_equal "<p>#{ideas(:first_idea).description}</p>", ideas(:first_idea).formatted_description
  end
  
  context "testing can edit?" do
    should "allow edit" do
      assert ideas(:no_comments_idea).can_edit?
    end
    
    should "not allow edit" do
      # no votes but has comments
      assert !ideas(:no_votes_idea).can_edit?
      assert !ideas(:new_votes_idea).can_edit?
    end
  end
  
  should "return status" do
    assert_equal "Open", ideas(:unscheduled_idea).display_status
    assert_equal "Scheduled", ideas(:first_idea).display_status
    assert_equal "Merged", ideas(:merged_idea).display_status
  end
  
  def test_list_unread_ideas 
    assert_nothing_thrown {
      Idea.list_unread_ideas(1, users(:allroles), {}, true)
      Idea.list_unread_ideas(1, users(:allroles), {}, false)
    }
  end
  
  def test_list_by_title_and_id
    ideas = Idea.list(1, users(:allroles), {}, true,
      "ideas.title like ? and ideas.id = ?",
      ["%#{ideas(:unscheduled_idea).title}%", ideas(:unscheduled_idea).id])
    assert_equal 1, ideas.size
  end

  def test_list_unread_comments
    assert_nothing_thrown {
      Idea.list_unread_comments(1, users(:allroles), {}, true)
      Idea.list_unread_comments(1, users(:allroles), {}, false)
    }
  end
  
  def test_list_product_and_user_filters
    assert_nothing_thrown {
      Idea.list(1, users(:allroles), 
        { :author_filter => users(:allocation_calculation_test).id.to_s,
          :product_filter => products(:producta).id.to_s,
          :release_filter => releases(:controller_test).id.to_s}, true)
    }
  end
  
  def test_list_voted_ideas
    assert_nothing_thrown {
      Idea.list_voted_ideas(1, users(:allroles), {}, true)
      Idea.list_voted_ideas(1, users(:allroles), {}, false)
    }
  end
  
  def test_list_commented_ideas
    assert_nothing_thrown {
      Idea.list_commented_ideas(1, users(:allroles), {}, true)
      Idea.list_commented_ideas(1, users(:allroles), {}, false)
    }
  end
  
  def test_list_most_votes
    assert_nothing_thrown {
      Idea.list_most_votes(1, users(:allroles), {}, true)
      Idea.list_most_votes(1, users(:allroles), {}, false)
    }
  end
  
  def test_list_most_views
    assert_nothing_thrown {
      Idea.list_most_views(1, users(:allroles), {}, true)
      Idea.list_most_views(1, users(:allroles), {}, false)
    }
  end
  
  def test_list_watched_ideas
    assert_nothing_thrown {
      Idea.list_watched_ideas(1, users(:allroles), {}, true)
      Idea.list_watched_ideas(1, users(:allroles), {}, false)
    }
  end
  
  def test_list_my_ideas
    assert_nothing_thrown {
      Idea.list_my_ideas(1, users(:allroles), {}, true)
      Idea.list_my_ideas(1, users(:allroles), {}, false)
    }
  end
  
  def test_title_too_long
    idea = Idea.new(
      :user_id => ideas(:first_idea).id,
      :product_id=>ideas(:first_idea).product_id,
      :release_id =>ideas(:first_idea). release_id,
      :title => 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz',
      :description  => 'dummy description'
    )
    assert !idea.valid?
    assert_equal "is too long (maximum is 100 characters)", 
      idea.errors.on(:title)
  end

  should "create_idea" do
    idea = Idea.new(
      :user_id => ideas(:first_idea).id,
      :product_id=>ideas(:first_idea).product_id,
      :title => 'title',
      :description  => 'description')
    assert idea.valid?
    assert idea.save
  end

  def test_uniqueness
    idea2 = Idea.new(
      :user_id => ideas(:first_idea).user_id,
      :product_id=>ideas(:first_idea).product_id,
      :release_id =>ideas(:first_idea). release_id,
      :title =>ideas(:first_idea).title,
      :description  => ideas(:first_idea).description)

    assert !idea2.save
    assert_equal ActiveRecord::Errors.default_error_messages[:taken], 
      idea2.errors.on(:title)
  end
  
  def test_rescind_vote
    user = users(:allocation_calculation_test)
    idea = ideas(:available_votes_calc_test1)
    assert_equal 44, user.available_votes
    assert_equal 0, idea.votes.count
    idea.vote(user)
    idea.vote(user)
    user = User.find(user.id)
    assert_equal 42, user.available_votes
    assert_equal 2, idea.votes.count
    
    idea.rescind_vote(user)
    user = User.find(user.id)
    assert_equal 43, user.available_votes
    assert_equal 1, idea.votes.count
    
    idea.rescind_vote(user)
    user = User.find(user.id)
    assert_equal 44, user.available_votes
    assert_equal 0, idea.votes.count
    
    # now trying to vote should fail as we have no more votes to rescind
    assert_raise(VoteException) {
      idea.rescind_vote(user)
    }
  end
  
  def test_vote
    # test data from fixtures: allocation data
    #   user 12
    #   user 20
    #      vote
    #      vote
    #   enterprise 10
    #   enterprise 5
    #      vote
    user = users(:allocation_calculation_test)
    idea = ideas(:available_votes_calc_test1)
    
    # we should start with 29 available votes tied to user allocations
    assert_equal 30, user.available_user_votes
    assert_equal 14, user.available_enterprise_votes
    assert_equal 44, user.available_votes
    assert_equal 0, idea.votes.size
    
    # this round should consume user allocations
    for i in 1..30
      idea.vote(user)
      user = User.find(user.id)
      assert_equal 44 - i, user.available_votes
      assert_equal 30 - i, user.available_user_votes
      assert_equal 14, user.available_enterprise_votes
      
      assert_equal i, idea.votes.count
    end
    
    # this round should consume enterprise allocations
    for i in 31..44
      idea.vote(user)
      user = User.find(user.id)
      assert_equal 44 - i, user.available_votes
      assert_equal 0, user.available_user_votes
      assert_equal 44 - i, user.available_enterprise_votes
      
      assert_equal i, idea.votes.count
    end
    
    assert_equal 0, user.available_votes
    assert_equal 0, user.available_user_votes
    assert_equal 0, user.available_enterprise_votes
    assert_equal 44, idea.votes.count
    
    # now trying to vote should fail as we have no more allocations
    assert_raise(VoteException) {
      assert !idea.vote(user)
    }
    assert_equal 0, user.available_votes
    assert_equal 0, user.available_user_votes
    assert_equal 0, user.available_enterprise_votes
    assert_equal 44, idea.votes.count
    
  end
  
  def test_rescindable_votes
    assert !ideas(:first_idea).rescindable_votes?(votes(:first_vote).user_id)
    assert !ideas(:no_votes_idea).rescindable_votes?(ideas(:no_votes_idea).user_id)
    assert ideas(:new_votes_idea).rescindable_votes?(users(:allocation_calculation_test).id)
  end
  
  def test_unread
    user = users(:allocation_calculation_test)
    idea = ideas(:first_idea)
    assert idea.unread?(user)
    read = idea.user_idea_reads.create(:user_id => user.id, :last_read => Time.zone.now)
    assert !idea.unread?(user)
    
    assert !idea.unread_comment?(user)
    sleep 1
    idea.comments << IdeaComment.new(:user_id => user.id, :body => "blah")
    idea.save
    assert idea.unread_comment?(user)
    sleep 1
    read.last_read = Time.zone.now
    read.save
    idea = Idea.find(idea.id)
    assert !idea.unread_comment?(user)
  end
  
  def test_last_comment
    user = users(:allocation_calculation_test)
    idea = ideas(:no_comments_idea)
    assert idea.comments.empty?
    assert_nil idea.last_comment
    comment1 = IdeaComment.new(:user_id => user.id, :body => "blah1")
    comment2 = IdeaComment.new(:user_id => user.id, :body => "blah2")
    idea.comments << comment1
    idea.comments << comment2
    idea.save
    idea = Idea.find(idea.id)
    assert_not_nil idea.last_comment
    assert !idea.last_comment?(comment1)
    assert idea.last_comment?(comment2)
  end
  
  context "an idea with change logs" do
    setup do
      @idea = ideas(:first_idea)
    end
    
    should "retrieve change logs" do
      assert !@idea.change_logs.empty?
      assert_equal 2, @idea.change_logs.size
    end
    
    should "retrieve active change logs" do
      assert !@idea.unprocessed_change_logs.empty?
      assert_equal 1, @idea.unprocessed_change_logs.size
    end
  end
end