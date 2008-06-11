class EnterprisesController < ApplicationController
  before_filter :login_required
  access_control :DEFAULT => 'sysadmin | allocmgr'
  
  def index
    @enterprises = Enterprise.list params[:page], current_user.row_limit
  end  
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

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
