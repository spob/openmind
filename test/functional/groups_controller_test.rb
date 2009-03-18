require File.dirname(__FILE__) + '/../test_helper'
require 'groups_controller'

# Re-raise errors caught by the controller.
class GroupsController; def rescue_action(e) raise e end; end

class GroupsControllerTest < ActionController::TestCase 
  fixtures :groups, :users

  def setup
    @controller = GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    login_as 'allroles'
  end

  context "on :get to :index" do
    setup { get :index }
    should_respond_with :success
    should_render_template 'index'
    should_not_set_the_flash
    should_assign_to :groups
  end

  context "on POST to :create" do
    setup { post :create, :group => { :name => 'xxx', :description => 'yyyy'} }
    should_respond_with :redirect
    should_redirect_to "groups_path"
    should_set_the_flash_to(/created/i)
  end

  context "on POST to :create with bad value" do
    setup { post :create, :group => { :name => 'xxx' } }
    
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should_assign_to :group
  end

  context "on GET to :show" do
    setup { get :show, :id => groups(:group1) }
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :group
  end
  
  context "on DELETE to :destroy" do
    setup { delete :destroy, :id => groups(:group1) }
    should_respond_with :redirect
    should_redirect_to "groups_path"
    should_set_the_flash_to(/deleted/i)
  end

  context "on GET to :edit" do
    setup { get :edit, :id => groups(:group1) }
    should_respond_with :success
    should_render_template 'edit'
    should_not_set_the_flash
    should_assign_to :group
  end

  context "on PUT to :update" do
    setup { put :update, :id => groups(:group1), :group => {} }
    
    should_respond_with :redirect
    should_redirect_to "groups_path"
    should_set_the_flash_to(/updated/i)
  end

  context "on PUT to :update with a bad value" do
    setup { put :update, :id => groups(:group1), :group => { :name => '' } }
    
    should_respond_with :success
    should_render_template :edit
    should_not_set_the_flash
    should_assign_to :group
  end
end
