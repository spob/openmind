require File.dirname(__FILE__) + '/../test_helper'
require 'forums_controller'

# Re-raise errors caught by the controller.
class ForumsController; def rescue_action(e) raise e end; end

class ForumsControllerTest < ActiveSupport::TestCase 
  fixtures :forums, :users, :lookup_codes, :topics, :comments

  def setup
    @controller = ForumsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    login_as 'allroles'
  end
  
  context "on get to :new" do
    setup { get :new }
    should_respond_with :success
    should_render_template 'new'
    should_not_set_the_flash
    should_assign_to :forum
  end
  
  context "on get to :show" do
    setup { get :show, :id => forums(:bugs_forum) }
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :forum
  end
  
  context "on get to :search" do
    setup { get :search, :search => "search"}
    should_respond_with :success
    should_render_template 'search'
    should_not_set_the_flash
    #    assert_nil flash[:error]`
    should_assign_to :hits
  end
  
  context "on get to :toggle_forum_details_box" do
    setup {get :toggle_forum_details_box, :id => forums(:bugs_forum) }
  end
  
  context "on get to :rss" do
    setup {get :rss }
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:forums)
  end

  def test_index_without_login
    login_as nil
    get :index

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:forums)
  end

  def test_create
    num_forums = Forum.count

    post :create, :forum => { :name => "x", :description => "desc" }
    
    assert_equal num_forums + 1, Forum.count
    assert_response :redirect
    assert_redirected_to :controller => 'forums', :action => 'index'

  end

  def test_edit
    assert_not_nil forums(:bugs_forum)
    get :edit, :id => forums(:bugs_forum)

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:forum)
    assert assigns(:forum).valid?
  end

  def test_update
    put :update, {:id => forums(:bugs_forum), :forum => {:mediator_ids => [] }}
    assert_response :redirect
    assert_redirected_to forum_path
  end

  def test_destroy
    assert_nothing_raised {
      Forum.find(forums(:bugs_forum).id)
    }

    delete :destroy, :id => forums(:bugs_forum).id
    assert_response :redirect
    assert_redirected_to forums_path

    assert_raise(ActiveRecord::RecordNotFound) {
      Forum.find(forums(:bugs_forum).id)
    }
  end
  
  def test_access_denied
    assert_equal "You must be logged on to access this forum", 
      ForumsController.flash_for_forum_access_denied(:false)
    assert_equal "You have insuffient permissions to access this forum", 
      ForumsController.flash_for_forum_access_denied(users(:quentin))
  end
end
