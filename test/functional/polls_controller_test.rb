require File.dirname(__FILE__) + '/../test_helper'
require 'polls_controller'

# Re-raise errors caught by the controller.
class PollsController; def rescue_action(e) raise e end; end

class PollsControllerTest < Test::Unit::TestCase
  fixtures :polls, :users

  def setup
    @controller = PollsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    login_as 'allroles'
  end


  def test_index
    get :index

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:polls)
  end

  def test_create
    num_polls = Poll.count

    post :create, :poll => { :title => "x", :close_date => 119.days.since.to_s(:db) }

    assert_response :redirect
    assert_redirected_to :controller => 'polls', :action => 'edit'

    assert_equal num_polls + 1, Poll.count
  end

  def test_edit
    get :edit, :id => polls(:color_poll)

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:poll)
    assert assigns(:poll).valid?
  end

  def test_update
    put :update, :id => polls(:color_poll)
    assert_response :redirect
    assert_redirected_to :controller => 'polls', :action => 'show',
      :id => polls(:color_poll).id
  end

  def test_destroy
    assert_nothing_raised {
      Poll.find(polls(:color_poll).id)
    }

    delete :destroy, :id => polls(:color_poll).id
    assert_response :redirect
    assert_redirected_to polls_path

    assert_raise(ActiveRecord::RecordNotFound) {
      Poll.find(polls(:color_poll).id)
    }
  end
end
