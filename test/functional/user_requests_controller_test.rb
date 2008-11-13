require File.dirname(__FILE__) + '/../test_helper'
require 'user_requests_controller'

# Re-raise errors caught by the controller.
class UserRequestsController; def rescue_action(e) raise e end; end

class UserRequestsControllerTest < Test::Unit::TestCase
  fixtures :user_requests, :users, :roles

  def setup
    @controller = UserRequestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login_as 'allroles'
  end

  context "send GET to :new" do
    setup { get :new }
    should_respond_with :success
    should_render_template 'new'
    should_not_set_the_flash
    should_assign_to :user_request
  end

  context "send POST to :create with bad values" do
    setup { post :create,
      :user_request => {
        :enterprise_name => "xxx"
      } 
    }
    should_respond_with :success
    should_render_template 'new'
    should_not_set_the_flash
    should_assign_to :user_request
  end

  context "send GET to :acknowledge" do
    setup { get :acknowledge, :id => user_requests(:pending)}
    should_respond_with :success
    should_render_template 'acknowledge'
    should_not_set_the_flash
    should_assign_to :user_request
  end

  context "send GET to :index (form_based)" do
    setup { get :index, :form_based => "yes"}
    should_respond_with :success
    should_render_template 'index'
    should_not_set_the_flash
    should_assign_to :user_requests
  end

  context "send GET to :index (none-form_based)" do
    setup { get :index, :form_based => "no"}
    should_respond_with :success
    should_render_template 'index'
    should_not_set_the_flash
    should_assign_to :user_requests
  end

  context "send DELETE to :destroy" do
    setup { delete :destroy, :id => user_requests(:pending)}
    should_respond_with :redirect
    should_redirect_to "user_requests_path"
    should_set_the_flash_to(/deleted/i)
  end

  context "send GET to :show" do
    setup { get :show, :id => user_requests(:pending) }
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :user_request
  end

  context "send GET to :edit" do
    setup { get :edit, :id => user_requests(:pending) }
    should_respond_with :success
    should_render_template 'edit'
    should_not_set_the_flash
    should_assign_to :user_request
  end

  context "send PUT to :update" do
    setup { put :update,
      :id => user_requests(:pending),
      :user_request => {
        :enterprise_name => "asdfas"
      }
    }
    should_redirect_to "user_requests_path"
    should_set_the_flash_to(/updated/)
  end

  context "send PUT to :update with bad values" do
    setup { put :update,
      :id => user_requests(:pending),
      :user_request => {
        :enterprise_name => ""
      }
    }
    should_respond_with :success
    should_render_template 'edit'
    should_not_set_the_flash
    should_assign_to :user_request
  end

  context "send POST to :reject" do
    setup { post :reject,
      :id => user_requests(:pending)
    }
    should_respond_with :redirect
    should_redirect_to "user_requests_path"
    should_set_the_flash_to(/rejected/)
  end

  context "send POST to :approve with new enterprise" do
    setup { post :approve,
      :id => user_requests(:pending)
    }
    should_respond_with :redirect
    should_set_the_flash_to(/approved/)
  end

  context "send POST to :approve with existing enterprise" do
    setup { post :approve,
      :id => user_requests(:pending)
    }
    should_respond_with :redirect
    should_set_the_flash_to(/approved/)
  end

  context "on GET to :next" do
    setup { get :next, :id => user_requests(:pending_existing_enterprise),
      :user_request => {
        :initial_enterprise_allocation => 5, :initial_user_allocation => 6
      }
    }
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :user_request
  end

  context "on GET to :previous" do
    setup { get :previous, :id => user_requests(:pending)}
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :user_request
  end
end
