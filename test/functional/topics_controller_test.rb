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
end
