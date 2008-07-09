class ForumsController < ApplicationController
  before_filter :login_required
  access_control [:new, :edit, :create, :update, :destroy ] => 'sysadmin'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

  def show
    @forum = Forum.find(params[:id])
  end
  
  def index
    @forums = Forum.list params[:page], current_user.row_limit
  end

  def create
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = "Forum #{@forum.name} was successfully created."
      redirect_to forums_path
    else
      index
      render :action => :index
    end
  end

  def edit
    @forum = Forum.find(params[:id])
    @mediators = Role.find_users_by_role('mediator')
  end

  def update
    params[:forum][:mediator_ids] ||= []
    @forum = Forum.find(params[:id])
    if @forum.update_attributes(params[:forum])
      flash[:notice] = "Forum '#{@forum.name}' was successfully updated."
      redirect_to forums_path
    else
      render :action => :edit
    end
  end

  def destroy
    forum = Forum.find(params[:id])
    name = forum.name
    forum.destroy
    flash[:notice] = "Forum #{name} was successfully deleted."
    redirect_to forums_url
  end
end