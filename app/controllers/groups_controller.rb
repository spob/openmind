class GroupsController < ApplicationController
  before_filter :login_required
  access_control [:new, :edit, :create, :update, :destroy ] => 'sysadmin'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  def index
    @group ||= Group.new
    @groups = Group.list params[:page], current_user.row_limit
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = "User group #{@group.name} was successfully created."
      redirect_to groups_path
    else
      index
      render :action => :index
    end
  end
  
  def show
    @group = Group.find(params[:id])
  end

  def destroy
    group = Group.find(params[:id])
    name = group.name
    group.destroy
    flash[:notice] = "User group #{name} was successfully deleted."
    redirect_to groups_url
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      flash[:notice] = "User group '#{@group.name}' was successfully updated."
      redirect_to groups_path
    else
      render :action => :edit
    end
  end
end