require File.dirname(__FILE__) + '/../test_helper'
require 'topics_controller'

# Re-raise errors caught by the controller.
class TopicsController; def rescue_action(e) raise e end; end

class TopicsControllerTest < Test::Unit::TestCase
  fixtures :topics, :users, :forums, :groups, :roles

  def setup
    @controller = TopicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    login_as 'allroles'
  end

  context "send GET to :new" do
    setup { get :new, :forum_id => topics(:bug_topic1).forum }
    should_respond_with :success
    should_render_template 'new'
    should_not_set_the_flash
    should_assign_to :forum
    should_assign_to :topic
    should_assign_to :comment
  end

  context "send GET to :new without access" do
    setup {
      login_as 'judy'
      get :new, :forum_id => forums(:forum_restricted_to_user_group)
    }
    should_respond_with :redirect
    should_redirect_to "forums_path"
    should_set_the_flash_to(/insuffient permissions/)
  end

  def test_index
    get :index

    assert_redirected_to forums_path
  end

  def test_create
    num_topics = Topic.count
    
    topic = Topic.find(:first)

    title = 5.days.ago.to_s(:db)
    post :create, :forum_id => topic.forum.id, 
      :topic => { :title=>title, :comment_body=>"fda"
    }

    assert_response :redirect
    assert_redirected_to forum_path(:id => topic.forum.id)

    assert_equal num_topics + 1, Topic.count
    topic = Topic.find_by_title(title)
    assert_not_nil topic
    assert 1, topic.comments.count
  end

  def test_edit
    get :edit, :id => topics(:bug_topic1)

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:topic)
    assert assigns(:topic).valid?
  end

  def test_update
    put :update, {:id => topics(:bug_topic1)}
    assert_response :redirect
    assert_redirected_to forum_path(topics(:bug_topic1).forum)
  end

  def test_destroy
    id = topics(:bug_topic1).id
    assert_nothing_raised {
      Topic.find(id)
    }
    delete :destroy, :id => id
    assert_response :redirect
    assert_redirected_to forum_path(topics(:bug_topic1).forum)

    assert_raise(ActiveRecord::RecordNotFound) {
      Topic.find(id)
    }
  end
end
