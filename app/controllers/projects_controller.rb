class ProjectsController < ApplicationController
  before_filter :login_required
  before_filter :fetch_project, :only => [:edit, :update, :destroy]

  verify :method      => :post, :only => [:create],
         :redirect_to => {:action => :index}
  verify :method      => :put, :only => [:update],
         :redirect_to => {:action => :index}
  verify :method      => :delete, :only => [:destroy],
         :redirect_to => {:action => :index}

  def index
    if can_view_projects?
      @projects = Project.list params[:page], current_user.row_limit
    end
  end


  def create
    if can_edit_projects?
      @project                 = Project.new(params[:project])
      if @project.save
        flash[:notice] = "Project was successfully created."
        redirect_to projects_path
      else
        index
        render :action => 'index'
      end
    end
  end

  def destroy
    name = @project.name || ""
    @project.destroy
    flash[:notice] = "Project #{name} was successfully deleted."
    redirect_to projects_path
  end

  private

  def can_view_projects?
    return true if current_user.developer?
    flash[:error] = "You do not have access to that page"
    redirect_to home_path
    false
  end

  def can_edit_projects?
    return true if current_user.developer? && current_user.sysadmin?
    flash[:error] = "You do not have access to edit a project"
    redirect_to proejcts_path
    false
  end

  def fetch_project
    @project = Project.find(params[:id])
  end
end
