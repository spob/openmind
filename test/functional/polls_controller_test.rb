require File.dirname(__FILE__) + '/../test_helper'
require 'polls_controller'

# Re-raise errors caught by the controller.
class PollsController; def rescue_action(e) raise e end; end

class PollsControllerTest < Test::Unit::TestCase
  fixtures :polls, :users, :poll_options

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
  
  def test_publish_unpublish
    assert !polls(:color_poll).active
    post :publish, :id => polls(:color_poll).id
    poll = Poll.find polls(:color_poll).id
    assert poll.active
    
    post :unpublish, :id => polls(:color_poll).id
    poll = Poll.find polls(:color_poll).id
    assert !poll.active
  end

  def test_show_survey
    get :show_survey, :id => polls(:color_poll)

    assert_response :success
    assert_template 'show_survey'
  end

  def test_take_survey
    option = poll_options(:color_poll_green_option)
    assert 75, option.percent_chosen
    assert 4, option.poll.total_responses
    post :take_survey, :id => polls(:color_poll).id, 
      :poll_option_id => option.id
    assert_redirected_to :action => "show"
    
    option = PollOption.find(option.id)
    assert 80, option.percent_chosen
    assert 5, option.poll.total_responses
    
    post :take_survey, :id => polls(:color_poll).id, 
      :poll_option_id => option.id
    assert_template 'show_survey'
    assert_equal "You can only answer this survey once", flash[:error]
  end
  
  def test_take_survey_no_selection
    post :take_survey, :id => polls(:color_poll).id
    assert_template 'show_survey'
    assert_equal "You must select an option", flash[:error]
  end
end
