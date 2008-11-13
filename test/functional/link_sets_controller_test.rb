require File.dirname(__FILE__) + '/../test_helper'
require 'link_sets_controller'

class LinkSetsControllerTest < ActionController::TestCase
  fixtures :link_sets, :users

  def setup
    @controller = LinkSetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login_as 'allroles'
  end
  
  context "send GET to :index" do
    setup { get :index }
    should_respond_with :success
    should_render_template 'index'
    should_not_set_the_flash
    should_assign_to :link_sets
    should_assign_to :link_set
  end
  
  context "send GET to :show" do
    setup { get :show, :id => link_sets(:first_link_set) }
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :link_set
  end
  
  context "send GET to :edit" do
    setup { get :edit, :id => link_sets(:first_link_set) }
    should_respond_with :success
    should_render_template 'edit'
    should_not_set_the_flash
    should_assign_to :link_set
  end
  
  context "send POST to :create" do
    setup { post :create, :link_set => {
        :name => "xxx1",
        :label => "yyy",
        :default_link_set => true 
      }
    }
    should_respond_with :redirect
    should_redirect_to "edit_link_set_path(@link_set)"
    should_set_the_flash_to(/successfully created/i)
  end
  
  context "send POST to :create with error" do
    setup { post :create, :link_set => {
        :name => "xxx2",
        :default_link_set => true }
    }
    should_respond_with :success
    should_render_template 'index'
    should_not_set_the_flash
  end
  
  context "send PUT to :update" do
    setup { put :update, :id => link_sets(:first_link_set),
      :link_set => {
        :name => "xxx1",
        :label => "yyy",
        :default_link_set => true 
      }
    }
    should_respond_with :redirect
    should_redirect_to "link_set_path(@link_set)"
    should_set_the_flash_to(/updated/i)
  end
  
  context "send PUT to :update with error" do
    setup { put :update, :id => link_sets(:first_link_set),
      :link_set => {
        :name => "",
        :default_link_set => true }
    }
    should_respond_with :success
    should_render_template 'edit'
    should_not_set_the_flash
  end
  
  context "send DELETE to :destroy" do
    setup { delete :destroy, :id => link_sets(:first_link_set) }
    should_respond_with :redirect
    should_redirect_to "link_sets_path"
    should_set_the_flash_to(/deleted/i)
  end
end
