class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :login_required, :only => [ :logout ]

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?    
    @login = params[:login] # needed to remember login info in login fails
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      self.current_user.user_logons.create
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , 
          :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default home_path
      expire_msg = expiration_msg
      flash[:notice] = "Logged in successfully" if expire_msg.nil?
      flash[:error] = "Logged in successfully#{expire_msg}" unless expire_msg.nil?
    else
      flash[:error] = "Login failed...please try again"
    end
  end
  
  def activate
    flash.clear  
    return if params[:id].nil? and params[:activation_code].nil?
    activator = params[:activation_code] || params[:id]
    @user = User.find_by_activation_code(activator) 
    if @user
      if @user.activate
        redirect_back_or_default(:controller => '/account', :action => 'login')
        flash[:notice] = "Your account has been activated. Please login."
      else
        flash[:error] = "Unable to activate the account. Please check or enter manually."
      end
    else
        flash[:error] = "Unable to activate the account: no such activation code '#{activator}'."
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default home_path
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'login')
  end
  
  def change_password
    return unless request.post?
    @user = self.current_user
    if params[:user][:password] != params[:user][:password_confirmation]
      flash[:error] = "Password confirmation must match" 
      render :action => 'change_password'
    elsif @user.authenticated?(params[:current_password])
      @user.update_attributes(params[:user])
      @user.update_attribute(:force_change_password, false)
      @user.save!
      flash[:notice] = "Password has been successfully changed." 
      redirect_to home_path
    else
      flash[:error] = "Password authentication failed" 
      render :action => 'change_password'
    end

  rescue ActiveRecord::RecordInvalid
    render :action => 'change_password'
  end
  
  private
  
  def expiration_msg
      expiration_days = Allocation.expiring_allocation_days self.current_user
      allocation_expiration_warning_days = APP_CONFIG['allocation_expiration_warning_days'].to_i
      return nil if expiration_days > allocation_expiration_warning_days or allocation_expiration_warning_days > 0
      ". You have allocations expiring in #{StringUtils.pluralize(expiration_days, 'day')} "
  end
end