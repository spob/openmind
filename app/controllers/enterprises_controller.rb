class EnterprisesController < ApplicationController
  before_filter :login_required
  access_control :DEFAULT => 'sysadmin | allocmgr'
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  
  def index
    session[:enterprise_start_filter] = params[:start_filter] unless params[:start_filter].nil?
    session[:enterprise_end_filter] = params[:end_filter] unless params[:end_filter].nil?
    session[:enterprise_start_filter] = "All" if session[:enterprise_start_filter].nil?
    session[:enterprise_end_filter] = "All" if session[:enterprise_end_filter].nil?
    count = Enterprise.count
    if count > 50
      @tag1_begin = Enterprise.find(:first, :select => "name", :order => "name").name
      @tag1_end = Enterprise.find(:first, :select => "name", :offset => count/5, :order => "name").name
      @tag2_begin = Enterprise.find(:first, :select => "name", :offset => count/5 + 1, :order => "name").name
      @tag2_end = Enterprise.find(:first, :select => "name", :offset => 2*count/5, :order => "name").name
      @tag3_begin = Enterprise.find(:first, :select => "name", :offset => 2*count/5 + 1, :order => "name").name
      @tag3_end = Enterprise.find(:first, :select => "name", :offset => 3*count/5, :order => "name").name
      @tag4_begin = Enterprise.find(:first, :select => "name", :offset => 3*count/5 + 1, :order => "name").name
      @tag4_end = Enterprise.find(:first, :select => "name", :offset => 4*count/5, :order => "name").name
      @tag5_begin = Enterprise.find(:first, :select => "name", :offset => 4*count/5 + 1, :order => "name").name
      @tag5_end = Enterprise.find(:first, :select => "name", :offset => count-1, :order => "name").name
    end
    @enterprises = Enterprise.list params[:page], current_user.row_limit, 
      session[:enterprise_start_filter], session[:enterprise_end_filter]
  end  

  def show
    @enterprise = Enterprise.find(params[:id])
  end
  
  def create
    @enterprise = Enterprise.new(params[:enterprise])
    if @enterprise.save
      flash[:notice] = "Enterprise #{@enterprise.name} was successfully created."
      redirect_to enterprises_path
    else
      index
      render :action => 'index'
    end  
  end
  
  def edit
    @enterprise  = Enterprise.find(params[:id])
  end  

  def update
    @enterprise = Enterprise.find(params[:id])
    if @enterprise.update_attributes(params[:enterprise])
      flash[:notice] = "Enterprise #{@enterprise.name} was successfully updated."
      redirect_to enterprise_path(@enterprise)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    enterprise = Enterprise.find(params[:id])
    name = enterprise.name
    enterprise.destroy
    flash[:notice] = "Enterprise #{name} was successfully deleted."
    redirect_to enterprises_path
  end  
  
end
