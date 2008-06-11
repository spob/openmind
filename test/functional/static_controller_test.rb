require File.dirname(__FILE__) + '/../test_helper'
require 'static_controller'

# Re-raise errors caught by the controller.
class StaticController; def rescue_action(e) raise e end; end

class StaticControllerTest < Test::Unit::TestCase
  def setup
    @controller = StaticController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
