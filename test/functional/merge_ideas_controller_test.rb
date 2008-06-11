require File.dirname(__FILE__) + '/../test_helper'
require 'merge_ideas_controller'

# Re-raise errors caught by the controller.
class MergeIdeasController; def rescue_action(e) raise e end; end

class MergeIdeasControllerTest < Test::Unit::TestCase
  fixtures :users, :enterprises, :roles_users, :ideas
  
  def setup
    @controller = MergeIdeasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as 'allroles'
  end
  
  def test_routing  
    with_options :controller => 'merge_ideas' do |test|
      test.assert_routing 'merge_ideas/1', :action => 'show', :id => '1'
    end
    assert_recognizes({:controller => 'merge_ideas', :action => 'create'},
      :path => 'merge_ideas', :method => :post)
    assert_recognizes({:controller => 'merge_ideas', :action => 'destroy', :id => "1"},
      :path => 'merge_ideas/1', :method => :delete)
  end
   
  def test_show_merge
    idea = ideas(:first_idea)
    get :show, :id => idea.id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:idea)
    assert assigns(:idea).valid?
  end
  
  def test_merge_and_unmerge
    idea = ideas(:first_idea)
    target_idea = ideas(:available_votes_calc_test1)
    assert_nil idea.merged_to_idea
    assert target_idea.merged_ideas.empty?
    assert_equal 3, idea.votes.size
    assert_equal 0, target_idea.votes.size
    
    # First merge
    post :create, :id => idea.id, :merged_into_idea_id  => target_idea.id

    assert_response :redirect
    assert_redirected_to :action => 'show'
    
    idea = Idea.find(idea.id)
    target_idea = Idea.find(target_idea.id)
    assert_not_nil idea.merged_to_idea
    assert !target_idea.merged_ideas.empty?
    
    assert_equal 0, idea.votes.size
    assert_equal 3, target_idea.votes.size
    
    # Now try to unmerge
    delete :destroy, :id => idea.id
    assert_response :redirect
    assert_redirected_to :action => 'show'
    idea = Idea.find(idea.id)
    target_idea = Idea.find(target_idea.id)
    assert_nil idea.merged_to_idea
    assert target_idea.merged_ideas.empty?
    
    assert_equal 0, idea.votes.size
    assert_equal 3, target_idea.votes.size
  end
end
