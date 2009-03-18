require File.dirname(__FILE__) + '/../test_helper'
require 'announcements_controller'

# Re-raise errors caught by the controller.
class AnnouncementsController; def rescue_action(e) raise e end; end

class AnnouncementsControllerTest < ActiveSupport::TestCase 
  fixtures :announcements, :users

  def setup
    @controller = AnnouncementsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = announcements(:normal1).id
    login_as 'allroles'
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:announcements)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:announcement)
  end

  def test_create
    num_announcements = Announcement.count

    post :create, :announcement => { :headline => "x", :description => "y"}

    assert_response :redirect
    assert_redirected_to announcements_path

    assert_equal num_announcements + 1, Announcement.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:announcement)
    assert assigns(:announcement).valid?
  end

  def test_update
    put :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to announcements_path
  end

  def test_destroy
    assert_nothing_raised {
      Announcement.find(@first_id)
    }

    delete :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to announcements_path

    assert_raise(ActiveRecord::RecordNotFound) {
      Announcement.find(@first_id)
    }
  end
  
  context "on GET to :show" do
    setup { get :show, :id => @first_id }
    
    should_respond_with :success
    should_render_template :show
    should_not_set_the_flash
    should_assign_to :announcement
  end
  
  context "on POST to :create with bad value" do
    setup { post :create, :announcement => {
        :headline => "x", :description => ""
      }
    }  
    should_respond_with :success
    should_render_template :new
    should_not_set_the_flash
    should_assign_to :announcement
  end
  
  context "on PUT to :update with bad value" do
    setup { put :update, :id => @first_id, :announcement => {
        :headline => "x", :description => ""
      }
    should_respond_with :success
    should_render_template :edit
    should_not_set_the_flash
    should_assign_to :announcement
    }
  end
end
