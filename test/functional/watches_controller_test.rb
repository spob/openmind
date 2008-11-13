require File.dirname(__FILE__) + '/../test_helper'
require 'watches_controller'

# Re-raise errors caught by the controller.
class WatchesController; def rescue_action(e) raise e end; end

class WatchesControllerTest < Test::Unit::TestCase
  fixtures :users, :watches, :ideas, :forums, :topics
  
  def setup
    @controller = WatchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as 'allroles'
  end
  
  def test_routing  
    assert_recognizes({:controller => 'watches', :action => 'create'},
      :path => 'watches', :method => :post)
    assert_recognizes({:controller => 'watches', :action => 'destroy', :id => "1"},
      :path => 'watches/1', :method => :delete)
  end

  context "send POST to :create_forum_watch" do
    setup { post :create_forum_watch, :id => forums(:bugs_forum)}
    should_respond_with :redirect
    should_redirect_to "forum_path(@forum)"
    should_set_the_flash_to(/watched/i)
  end

  context "send POST to :create_topic_watch" do
    setup { post :create_topic_watch, :id => topics(:bug_topic1)}
    should_respond_with :redirect
    should_redirect_to "topic_path(@topic)"
    should_set_the_flash_to(/watched/i)
  end

  context "send DELETE to :destroy_forum_watch" do
    setup { delete :destroy_forum_watch, :id => forums(:bugs_forum)}
    should_respond_with :redirect
    should_redirect_to "forum_path(@forum)"
    should_set_the_flash_to(/Watch removed/i)
  end

  context "send DELETE to :destroy_topic_watch" do
    setup { delete :destroy_topic_watch, :id => topics(:bug_topic1)}
    should_respond_with :redirect
    should_redirect_to "topic_path(@topic)"
    should_set_the_flash_to(/Watch removed/i)
  end

  # Replace this with your real tests.
  def test_add_watch
    user = users(:allroles)
    idea = Idea.find(:first)
    assert user.watched_ideas.empty?

    post :create, :id => idea.id

    assert_response :redirect
    assert_redirected_to :action => 'show'
    
    user = User.find(user.id)
    assert !user.watched_ideas.empty?
    assert_equal idea.id, user.watched_ideas[0].id
    
    delete :destroy, :id => idea.id
    assert_response :redirect
    assert_redirected_to :action => 'show'
    user = User.find(user.id)
    assert user.watched_ideas.empty?
  end
end