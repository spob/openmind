require File.dirname(__FILE__) + '/../test_helper'
require 'polls_controller'

# Re-raise errors caught by the controller.
class PollsController; def rescue_action(e) raise e end; end

class PollsControllerTest < Test::Unit::TestCase
  fixtures :polls

  def setup
    @controller = PollsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
