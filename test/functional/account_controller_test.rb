require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActiveSupport::TestCase 
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users, :enterprises, :roles, :lookup_codes

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    post :login, :login => 'quentin@example.com', :password => 'secret'
    assert session[:user]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin@example.com', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_fail_login_for_inactive_enterprise
    post :login, :login => 'inactiveenterprise@example.com', :password => 'secret'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_fail_login_for_inactive_user
    post :login, :login => 'inactive@example.com', :password => 'secret'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_allow_signup
    assert_difference 'User.count', 1 do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end
  
  def test_should_activate_user
    assert_nil User.authenticate(users(:aaron).email, 'secret')
    get :activate, :id => users(:aaron).activation_code
    assert_equal users(:aaron), User.authenticate(users(:aaron).email, 'secret')
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count', 1 do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:user]
    assert_response :redirect
  end

  def test_should_remember_me
    post :login, :login => 'quentin@example.com', :password => 'secret', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :login => 'quentin@example.com', :password => 'secret', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  # changed logic to not delete on logout
  def test_should_not_delete_token_on_logout
    login_as :quentin
    get :logout
    assert_nil @response.cookies["auth_token"]
  end

  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.days.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    assert !@controller.send(:logged_in?)
  end
  

  def test_change_password_bad_current_pw
    login_as 'prodmgr'

    post :change_password, {:current_password => 'bad', 
      :user => { 
        :password => "password",
        :password_confirmation => "password"
      }}
    assert_response :success
    assert_template 'change_password'
    
    # password not changed
    assert User.find(users(:prodmgr).id).authenticated?('secret')
  end

  def test_change_password_bad_pw_confirmation
    login_as 'prodmgr'

    assert User.find(users(:prodmgr).id).authenticated?('secret')
    post :change_password, {:current_password => 'secret', 
      :user => { 
        :password => "password",
        :password_confirmation => "passwordx"
      }}
    assert_response :success
    assert_template 'change_password'
    
    # password not changed
    assert User.find(users(:prodmgr).id).authenticated?('secret')
  end

  def test_change_password_bad_pw
    login_as 'prodmgr'

    post :change_password, {:current_password => 'secretxx', 
      :user => { 
        :password => "p",
        :password_confirmation => "p"
      }}
    assert_response :success
    assert_template 'change_password'
    
    # password not changed
    assert User.find(users(:prodmgr).id).authenticated?('secret')
  end

  def test_change_password
    login_as 'prodmgr'

    post :change_password, {:current_password => 'secret', 
      :user => { 
        :password => "newpassword",
        :password_confirmation => "newpassword"
      }}
    assert_response :redirect
    
    # password changed
    assert User.find(users(:prodmgr).id).authenticated?('newpassword')
  end
  
  def test_force_change_password
    login_as 'force_change_pw'
    get :logout
    assert_response :redirect
    assert_redirected_to :action => "change_password"
  end

  def test_should_not_activate_nil
    get :activate, :activation_code => nil
    assert_activate_error
  end

  def test_should_not_activate_bad
    get :activate, :activation_code => 'foobar'
    assert flash.has_key?(:error), "Flash should contain error message." 
    assert_activate_error
  end

  def assert_activate_error
    assert_response :success
    assert_template "account/activate" 
  end

  protected
  def create_user(options = {})
    post :signup, :user => { :login => 'quire', 
      :email => 'quire@example.com', 
      :password => 'quire', 
      :password_confirmation => 'quire',
      :last_name => 'Smith',
      :enterprise_id => enterprises(:active_enterprise).id }.merge(options)
  end
    
  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token users(user).remember_token
  end
end
