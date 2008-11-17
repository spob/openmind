require File.dirname(__FILE__) + '/../test_helper'
require 'attachments_controller'

# Re-raise errors caught by the controller.
class AttachmentsController; def rescue_action(e) raise e end; end

class AttachmentsControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @controller = AttachmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as 'allroles'
  end
  
  context "on :get to :index" do
    setup { get :index }
    should_respond_with :success
    should_render_template 'index'
    should_not_set_the_flash
    should_assign_to :attachments
  end

  context "on POST to :create with bad value" do
    setup { post :create, :attachment => { :file => '' } }
    
    should_respond_with :success
    should_render_template :index
    should_set_the_flash_to(/Please specify a file/)
    should_assign_to :attachments
  end
end
