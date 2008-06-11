require File.dirname(__FILE__) + '/../test_helper'
require 'comments_controller'

# Re-raise errors caught by the controller.
class CommentsController; def rescue_action(e) raise e end; end

class CommentsControllerTest < Test::Unit::TestCase
  fixtures :comments, :users, :roles_users, :ideas

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = comments(:first_comment).id
    @idea_id = comments(:first_comment).idea_id
    @user_id = comments(:first_comment).user_id
    login_as 'allroles'
  end
  
  def test_routing  
    assert_recognizes({:controller => 'products', :action => 'create'},
      :path => 'products', :method => :post)
  end

  def test_new
    get :new, :id => @first_id

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:comment)
  end

  def test_update
    put :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Comment.find(@first_id)
    }

    delete :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Comment.find(@first_id)
    }
  end
end
