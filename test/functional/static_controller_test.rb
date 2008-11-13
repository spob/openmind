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

  context "send GET to :index" do
    setup { get :index, :path => 'help'}
    should_respond_with :success
    should_render_template 'help'
    should_not_set_the_flash
  end
end
