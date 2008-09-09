class UserRequestsController < ApplicationController
  before_filter :login_required, :except => [:new, :create]
  access_control [:edit, :update, :destroy, :show, :index] => 'sysadmin'
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  def new
    @user_request = UserRequest.new
    
    @user_request.time_zone = TimeZoneUtils.current_timezone.name
  end

  def create
    @user_request = UserRequest.new(params[:user_request])
    @user_request.status = UserRequest.pending
    if !User.find_by_email(@user_request.email).nil?
      flash[:notice] = "An account already exists for #{@user_request.email}. Select the 'Forgot your password?' link below to retrieve your password."
      redirect_to :controller => 'account', :action => 'login'
    elsif @user_request.save
      flash[:notice] = 'Your account request has been received. You will receive an email when your account has been approved.'
      redirect_to :controller => 'account', :action => 'login'
    else
      render :action => 'new'
    end
  end
  
  def index
    @user_requests = UserRequest.list params[:page], current_user.row_limit
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
  end

  def update
    @user_request = UserRequest.find(params[:id])
    if @user_request.update_attributes(params[:user_request])
      flash[:notice] = 'Account request was successfully updated.'
      redirect_to user_requests_path
    else
      render :action => 'edit'
    end
  end
end