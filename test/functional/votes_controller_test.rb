require File.dirname(__FILE__) + '/../test_helper'
require 'votes_controller'

# Re-raise errors caught by the controller.
class VotesController; def rescue_action(e) raise e end; end

class VotesControllerTest < Test::Unit::TestCase
  # BOB -- So, I'm supposed to include this? 
  # I don't think you need it...
  # include AuthenticatedTestHelper
  fixtures :ideas, :users, :roles_users, :votes, :allocations

  def setup
    @controller = VotesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @first_id = Idea.find(:first)
    login_as 'allroles'
  end
  
  def test_routing  
    with_options :controller => 'votes' do |test|
      test.assert_routing 'votes', :action => 'index'
    end
    assert_recognizes({:controller => 'votes', :action => 'create'},
      :path => 'votes', :method => :post)
    assert_recognizes({:controller => 'votes', :action => 'destroy', :id => "1"},
      :path => 'votes/1', :method => :delete)
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    
    assert_not_nil assigns(:votes)
  end
  
  def test_vote
    allocations_count = users(:allroles).available_votes
   
    num_votes = Vote.find(:all).size
    for i in 1..allocations_count
      post :create, :id => @first_id
      assert_response :redirect
      assert_redirected_to :action => 'show'
      assert_equal "Vote recorded for idea number 1 and idea is being watched", 
        flash[:notice] if i == 1
      assert_equal "Vote recorded for idea number 1", 
        flash[:notice] unless i == 1
      # force reload of user from the database to get the latest non-cached values
      assert_equal allocations_count - i, 
        User.find(users(:allroles).id).available_votes
      assert_equal num_votes + 1, Vote.find(:all).size
      num_votes += 1
    end
    post :create, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show'
    assert_equal "You don't have enough votes available to vote", 
      flash[:notice]
    # force re-read from the database so size value won't be cached
    assert_equal 0, User.find(users(:allroles).id).available_votes
    
    num_votes = Vote.find(:all).size
    delete :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show'
    assert_equal "Vote rescinded for idea number 1", 
      flash[:notice]
    assert_equal num_votes - 1, Vote.find(:all).size
  end
end