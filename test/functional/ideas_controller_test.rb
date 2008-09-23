require File.dirname(__FILE__) + '/../test_helper'
require 'ideas_controller'

# Re-raise errors caught by the controller.
class IdeasController; def rescue_action(e) raise e end; end

class IdeasControllerTest < Test::Unit::TestCase
  fixtures :ideas, :users, :products, :releases

  def setup
    @controller = IdeasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @idea_id = ideas(:first_idea).id
    login_as 'allroles'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:ideas)
  end

  def test_show
    idea = Idea.find(@idea_id)
    assert_equal 0, idea.view_count
    get :show, :id => @idea_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:idea)
    assert assigns(:idea).valid?
    
    idea = Idea.find(@idea_id)
    assert_equal 1, idea.view_count
    
    # now make sure that the last_read value is being updated properly
    user_idea_read = UserIdeaRead.find_by_idea_id(@idea_id)
    time = user_idea_read.last_read
    
    sleep 1 # sleep to make sure times are different
    get :show, :id => @idea_id
    assert UserIdeaRead.find_by_idea_id(@idea_id).last_read.to_f > time.to_f
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:idea)
  end

  def test_create
    num_ideas = Idea.count

    post :create, :idea => {
      :user_id => ideas(:first_idea).id,
      :product_id=>ideas(:first_idea).product_id,
      :release_id =>ideas(:first_idea). release_id,
      :title => 'dummy title',
      :description  => 'dummy description'
    }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_ideas + 1, Idea.count
  end

  def test_edit
    get :edit, :id => @idea_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:idea)
    assert assigns(:idea).valid?
  end

  def test_update
    post :update, :id => @idea_id
    assert_response :redirect
    assert_redirected_to :action => 'show'
  end

  def test_destroy
    assert_nothing_raised {
      Idea.find(@idea_id)
    }

    post :destroy, :id => @idea_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Idea.find(@idea_id)
    }
  end
  
  def test_cascading_delete
    idea = Idea.find(@idea_id)
    assert idea.votes.size > 0
    vote_id = idea.votes(:first).id
    idea.destroy
    assert_raise(ActiveRecord::RecordNotFound) { 
      Vote.find(vote_id) 
    }    
  end
 
end