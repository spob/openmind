module AuthenticatedSystem
  protected
  # Returns true or false if the user is logged in.
  # Preloads @current_user with the user model if they're logged in.
  def logged_in?
    current_user != :false
  end
    
  # Accesses the current user from the session.
  def current_user
    @current_user ||= (session[:user] && User.find_by_id(session[:user])) || :false
  end
    
  # Store the given user in the session.
  def current_user=(new_user)
    session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
    @current_user = new_user
  end
    
  # Check if the user is authorized.
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the user
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorize?
  #    current_user.login != "bob"
  #  end
  def authorized?
    true
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_filter :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_filter :login_required
  #
  def login_required
    username, passwd = get_auth_data
    self.current_user ||= User.authenticate(username, passwd) || :false if username && passwd
    success = logged_in? && authorized? ? true : access_denied
    success = force_password_change if success
    success = offer_poll if success
    success
  end
    
  # redirect to change password screen if required
  def force_password_change
    unless self.current_user.nil?
      if self.current_user.force_change_password
        redirect_to :controller => '/account', :action => 'change_password'
        flash[:notice] = "Please change your password"
        return false
      end
    end
    return true
  end
  
  def offer_poll
    unless self.current_user.nil? or session[:check_for_polls] == "OFFERED" or !voter?
      session[:check_for_polls] = "OFFERED"
      polls = self.current_user.open_polls.find_all{|poll| poll.can_take? current_user }
      if !polls.empty?
        @poll = polls[0]
        redirect_to present_survey_poll_path(@poll)
        flash[:notice] = "Would you like to participate in a survey?"
        return false
      end
    end
    return true
  end
    
  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    respond_to do |accepts|
      accepts.html do
        store_location
        redirect_to :controller => '/account', :action => 'login'
      end
      accepts.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render :text => "Could't authenticate you", :status => '401 Unauthorized'
      end
    end
    false
  end  
    
  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end
    
  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end
    
  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?
  end

  # When called with before_filter :login_from_cookie will check for an :auth_token
  # cookie and log the user back in if apropriate
  def login_from_cookie
    store_location
    return unless cookies[:auth_token] && !logged_in?
    user = User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      user.remember_me
      self.current_user = user
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      logged_in
#      flash[:notice] = "Logged in successfully"
    end
  end

  
  def logged_in
    self.current_user.user_logons.create
    # put the current user's email in the session for ease of debugging
    session[:current_user] = current_user.email
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies.delete :auth_token
      cookies[:auth_token] = { :value => self.current_user.remember_token , 
        :expires => self.current_user.remember_token_expires_at }
    end
    redirect_back_or_default home_path
    login_msg = pending_user_requests_msg
    login_msg = expiration_msg  if login_msg.nil?
    flash[:notice] = "Logged in successfully" if login_msg.nil?
    flash[:error] = "Logged in successfully. #{login_msg}" unless login_msg.nil?
  end

  private
  @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
  # gets BASIC auth info
  def get_auth_data
    auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
  end
  
  def expiration_msg
    expiration_days = Allocation.expiring_allocation_days self.current_user
    allocation_expiration_warning_days = APP_CONFIG['allocation_expiration_warning_days'].to_i
    return nil if expiration_days > allocation_expiration_warning_days or allocation_expiration_warning_days == 0
    "You have allocations expiring in #{StringUtils.pluralize(expiration_days, 'day')} "
  end
  
  def pending_user_requests_msg
    "You have account requests pending approval. " if sysadmin? and UserRequest.pending_requests?
  end
  
  def add_trailing_slash str
    str = str + '/' unless str.blank? or str =~ /\/$/
    str
  end
end
