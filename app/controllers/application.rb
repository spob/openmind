# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem 
  helper_method :prodmgr?, :voter?, :allocmgr?, :sysadmin?, :can_edit_idea?, 
    :can_delete_idea?, :flash_error_string, :flash_notice_string
  filter_parameter_logging :password, :password_confirmation
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_OpenMind_session_id'
  
  before_filter :login_from_cookie

  def login_from_cookie
    # what it's saying is, if theres no session var but there is the token 
    # cookie then do the following
    return unless session[:user].nil? && cookies[:auth_token]
    user = User.find_by_remember_token(cookies[:auth_token])
    if !user.nil? 
      if user.remember_token_expires_at >= Time.now
        self.current_user = user
        self.current_user.user_logons.create
      end
    end
  end
  
  def prodmgr?
    pmgr = false
    restrict_to 'prodmgr' do 
      pmgr = true
    end
    pmgr
  end
  
  def voter?
    voter = false
    restrict_to 'voter' do 
      voter = true
    end
    voter
  end
  
  def sysadmin?
    sysadmin = false
    restrict_to 'sysadmin' do 
      sysadmin = true
    end
    sysadmin
  end
  
  def allocmgr?
    allocmgr = false
    restrict_to 'allocmgr' do 
      allocmgr = true
    end
    allocmgr
  end
  
  def flash_error_string text
    "<img src='/themes/#{APP_CONFIG['app_theme']}/images/icons/32x32/flashError.png' alt='' /> #{text}"
  end
  
  def flash_notice_string text
    "<img src='/themes/#{APP_CONFIG['app_theme']}/images/icons/32x32/flashNotice.png' alt='' /> #{text}"
  end
  
  #
  # The follow methods are moved to the application level because they are
  # helper methods (see helper_method declaration above) that must be used by
  # the voter, watch, and ideas controllers
  #
  
  def can_delete_idea?(idea)
    (prodmgr? or voter?) and idea.can_delete? and idea.user.id == current_user.id
  end
  
  def can_edit_idea? idea
    prodmgr? or (voter? and idea.can_edit? and idea.user.id == current_user.id)
  end
end
