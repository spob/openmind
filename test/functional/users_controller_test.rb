require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users, :enterprises
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    login_as 'allroles'
    @first_id = users(:prodmgr).id
  end
  
  def test_lost_password
    get :lost_password
    assert_response :success
    assert_template 'lost_password'
    assert_nil users(:prodmgr).activation_code
    assert !users(:prodmgr).activated_at.nil?
    
    post :lost_password, :email => users(:prodmgr).email
    assert_response :redirect
    assert_redirected_to :controller => 'ideas', :action => 'index'
    user = User.find(users(:prodmgr).id)
    assert !user.activation_code.nil?
    assert_nil user.activated_at
    email = @emails.first
    assert_equal "OpenMind: Password reset, please activate your account", email.subject
  end

  context "send POST to :reset_password" do
    setup { post :reset_password, :id => users(:prodmgr) }
    should_respond_with :redirect
    should_set_the_flash_to(/reset/)
    should_assign_to :user
  end

  context "send POST to :export" do
    setup { post :export }
  end

  def test_index
    (1..105).each do |i|
      User.create!(
        :last_name => "user#{i}",
        :email => "user#{i}@x.com",
        :password => "password",
        :password_confirmation => "password",
        :enterprise_id => enterprises(:active_enterprise).id)
    end
    get :index
    assert_response :success
    assert_template 'list'
    
    assert_not_nil assigns(:users)
  end

  context "on GET to :next" do
    setup { get :next, :id => users(:prodmgr)}
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :user
  end

  context "on GET to :previous" do
    setup { get :previous, :id => users(:prodmgr)}
    should_respond_with :success
    should_render_template 'show'
    should_not_set_the_flash
    should_assign_to :user
  end

  context "on GET to :edit_profile" do
    setup { get :edit_profile}
    should_respond_with :success
    should_render_template 'edit_profile'
    should_not_set_the_flash
    should_assign_to :user
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:users)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user)
  end

  def test_create
    num_users = User.count

    post :create, :user => {
      :email => "blah@blah.org",
      :password => "password",
      :password_confirmation => "password",
      :last_name => "smith",
      :enterprise_id => enterprises(:active_enterprise).id,
      :role_ids => Role.find(:all).collect(&:id) 
    }

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_users + 1, User.count
    
    user = User.find_by_email("blah@blah.org")
    assert_equal Role.count, user.roles.length
  end

  def test_create_duplicate
    post :create, :user => { 
      :email => "prodmgr@example.com",
      :password => "password",
      :initial_allocation => "",
      :last_name => "smith",
      :password_confirmation => "password"
    }

    assert_response 200
    assert_template 'users/new'
  end
  
  def test_process_imported
    assert_nil users(:imported_user).activation_code
    post :process_imported
    assert_equal "Processed 1 imported user" , flash[:notice]
    assert_response :redirect
    assert_redirected_to :action => 'list'
    u = User.find(users(:imported_user).id)
    assert_not_nil u.activation_code
    
    post :process_imported
    assert_equal "Processed 0 imported users" , flash[:notice]
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_no_last_name
    post :create, :user => {
      :email => "blah@blah.org",
      :password => "password",
      :password_confirmation => "password",
      :enterprise_id => enterprises(:active_enterprise).id,
      :initial_allocation => "",
      :role_ids => Role.find(:all).collect(&:id) 
    }

    assert_response 200
    assert_template 'users/new'
  end

  def test_create_bad_email
    post :create, :user => { 
      :email => "blahblah.org",
      :password => "password",
      :last_name => "smith",
      :last_name => "smith",
      :password_confirmation => "password",
      :enterprise_id => enterprises(:active_enterprise).id
    }

    assert_response 200
    assert_template 'users/new'
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_update_null_email
    user = users(:prodmgr)
    user.email = nil
    post :update, { :id => user.id,
      :user => { :login => user.login, 
        :email => nil,
        :enterprise_id => enterprises(:active_enterprise).id }}
    assert_response 200
    assert_template 'users/edit'
  end

  def test_destroy
    assert_nothing_raised {
      User.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(@first_id)
    }
  end

  def test_update
    post :update, { :id => @first_id, :user => {:role_ids => [] }}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_edit_profile
    post :update_profile, { :id => @first_id, 
      :user => {:last_name => "sturim", :row_limit => 6, 
        :time_zone => "Mexico City",  
        :watch_on_vote => "0"      }}
    assert_response :redirect
    user = User.find(@first_id)
    assert_equal "Mexico City", user.time_zone
  end
  
  def test_add_roles
    id = users(:user_no_roles).id
    user = User.find(id)
    assert_equal 0, user.roles.length
    
    post :update, { :id => id, :user => {:role_ids => Role.find(:all).collect(&:id) }}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => id
    
    user = User.find(id)
    assert_equal Role.count, user.roles.length
    
    post :update, { :id => id, :user => {:role_ids => [] }}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => id
    user = User.find(id)
    assert_equal 0, user.roles.length
  end
end
