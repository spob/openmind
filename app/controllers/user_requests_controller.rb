class UserRequestsController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :acknowledge]
  access_control [:edit, :update, :destroy, :show, :index] => 'sysadmin'
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :approve, :reject ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  def new
    @user_request = UserRequest.new
    
    @user_request.time_zone = APP_CONFIG['default_user_timezone']
  end

  def create
    @user_request = UserRequest.new(params[:user_request])
    @user_request.status = UserRequest.pending
    @user_request.enterprise = Enterprise.find_by_active(true, 
      :conditions => ["name like ?", "%#{@user_request.enterprise_name}%"], 
      :order => "name ASC")
    
    if simple_captcha_valid? 
      if !User.find_by_email(@user_request.email).nil?
        flash[:error] = "An account already exists for #{@user_request.email}. Select the 'Forgot your password?' link below to retrieve your password."
        redirect_to :controller => 'account', :action => 'login'
      elsif @user_request.save
        flash[:notice] = 'Your account request has been received.'
        redirect_to acknowledge_user_request_path(@user_request)
      else
        render :action => 'new'
      end
    else  
      flash[:error] = "Verification failed...please try again"
      redirect_to :action => 'new'
    end  
  end
  
  def acknowledge
    @user_request = UserRequest.find(params[:id])
  end
  
  def index
    if params[:form_based] == "yes"
      session[:user_requests_pending] = (params[UserRequest.pending].nil? ? "no" : "yes")
      session[:user_requests_rejected] = (params[UserRequest.rejected].nil? ? "no" : "yes")
      session[:user_requests_approved] = (params[UserRequest.approved].nil? ? "no" : "yes")
    else
      session[:user_requests_pending] ||= "yes"
      session[:user_requests_pending] = params[UserRequest.pending] unless params[UserRequest.pending].nil?
      session[:user_requests_rejected] ||= "no"
      session[:user_requests_rejected] = params[UserRequest.rejected] unless params[UserRequest.rejected].nil?
      session[:user_requests_approved] ||= "no"
      session[:user_requests_approved] = params[UserRequest.approved] unless params[UserRequest.approved].nil?
    end
    statuses = []
    statuses << UserRequest.pending if session[:user_requests_pending] == "yes"
    statuses << UserRequest.approved if session[:user_requests_approved] == "yes"
    statuses << UserRequest.rejected if session[:user_requests_rejected] == "yes"
    @user_requests = UserRequest.list params[:page], current_user.row_limit, statuses
  end

  def destroy
    UserRequest.find(params[:id]).destroy
    flash[:notice] = "User request was successfully deleted."
    redirect_to user_requests_path
  end

  def show
    @user_request = UserRequest.find(params[:id])
  end

  def edit
    @user_request = UserRequest.find(params[:id])
    setup_values
  end

  def update
    @user_request = UserRequest.find(params[:id])
    if @user_request.update_attributes(params[:user_request])
      flash[:notice] = 'Account request was successfully updated.'
      redirect_to user_requests_path
    else
      setup_values
      render :action => 'edit'
    end
  end
  
  def reject
    @user_request = UserRequest.find(params[:id])
    @user_request.status = UserRequest.rejected
    if @user_request.save
      flash[:notice] = "Account request '#{@user_request.email}' rejected"
    end
    redirect_to user_requests_path
  end
  
  def approve
    @user_request = UserRequest.find(params[:id])
    
    unless User.find_by_email(@user_request.email).nil?
      flash[:error] = "User '#{@user_request.email}' already exists"
      redirect_to user_requests_path
      return
    end
    
    UserRequest.transaction do
    
      if @user_request.enterprise.nil?
        # is there an exact match?
        enterprise = Enterprise.find_by_name(@user_request.enterprise_name)
        if enterprise.nil?
          Enterprise.new(:name => @user_request.enterprise_name).save! 
          enterprise = Enterprise.find_by_name(@user_request.enterprise_name)
        end
      else
        enterprise = @user_request.enterprise
      end
    
      if @user_request.initial_enterprise_allocation > 0
        EnterpriseAllocation.new(:quantity => @user_request.initial_enterprise_allocation,
          :comments => "",
          :enterprise => enterprise,
          :expiration_date => Allocation.calculate_expiration_date).save!
      end
    
      user = User.new(:email => @user_request.email, :first_name => @user_request.first_name,
        :last_name => @user_request.last_name, :enterprise => enterprise)
      user.new_random_password
      user.roles << Role.find_default_roles
      user.save!
    
      if @user_request.initial_user_allocation > 0
        UserAllocation.new(:quantity => @user_request.initial_user_allocation,
          :comments => "",
          :user => User.find_by_email(@user_request.email),
          :expiration_date => Allocation.calculate_expiration_date).save!
      end
    
      @user_request.status = UserRequest.approved
      if @user_request.save!
        flash[:notice] = "Account request '#{@user_request.email}' approved"
        redirect_to :controller => 'users', :action => 'show', :id => user
      end
    end
  end
  
  private
  
  def setup_values
    @enterprises = Enterprise.active_enterprises 
    enterprise = Enterprise.new(:id => 0, :name => "Create new enterprise...") 
    @enterprises.insert(0, enterprise)
  end
end