require File.dirname(__FILE__) + '/../test_helper'
require 'topics_controller'

# Re-raise errors caught by the controller.
class TopicsController; def rescue_action(e) raise e end; end

class TopicsControllerTest < Test::Unit::TestCase
  fixtures :topics, :users

  def setup
    @controller = TopicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    login_as 'allroles'
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
end
