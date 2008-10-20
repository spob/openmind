class ForumsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  access_control [:new, :edit, :create, :update, :destroy ] => 'sysadmin'
  helper :topics

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }


  def new
    @forum = Forum.new
    @mediators = Role.find_users_by_role('mediator')
  end
  
  def show
    @forum = Forum.find(params[:id])
    unless @forum.can_see? current_user or prodmgr?
      flash[:error] = "You have insuffient permissions to access forum"
      redirect_to forums_path
    end
  end
  
  def index
    @forums = Forum.list params[:page], (current_user == :false ? 10 : current_user.row_limit)
  end

  def create
    params[:forum][:mediator_ids] ||= []
    params[:forum][:group_ids] ||= []
    params[:forum][:enterprise_type_ids] ||= []
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = "Forum #{@forum.name} was successfully created."
      redirect_to forums_path
    else
      @mediators = Role.find_users_by_role('mediator')
      render :action => :new
    end
  end

  def edit
    @forum = Forum.find(params[:id])
    @mediators = Role.find_users_by_role('mediator')
  end

  def update
    params[:forum][:mediator_ids] ||= []
    params[:forum][:group_ids] ||= []
    params[:forum][:enterprise_type_ids] ||= []
    @forum = Forum.find(params[:id])
    if @forum.update_attributes(params[:forum])
      flash[:notice] = "Forum '#{@forum.name}' was successfully updated."
      redirect_to forum_path(@forum)
    else
      render :action => :edit
    end
  end
  
  def search
    @hits = {}
    session[:forums_search] = params[:search]
    Topic.find_with_index(params[:search]).each do |topic|
      @hits[topic.id] = TopicHit.new(topic, true) if topic.forum.can_see?(current_user) or prodmgr?
    end
    TopicComment.find_with_index(params[:search]).each do |comment|
      if comment.topic.forum.can_see?(current_user) or prodmgr?
        # first see if topic hit already exists
        topic_hit = @hits[comment.topic.id]
        if topic_hit.nil?
          hit = TopicHit.new(comment.topic, false)
          hit.comments << comment 
          @hits[comment.topic.id] = hit
        else
          topic_hit.comments << comment
        end	
      end
    end
  end

  def destroy
    forum = Forum.find(params[:id])
    name = forum.name
    forum.destroy
    flash[:notice] = "Forum #{name} was successfully deleted."
    redirect_to forums_url
  end
  
  def toggle_forum_details_box
    @forum = Forum.find(params[:id])
    if session[:forum_details_box_display] == "SHOW"
      session[:forum_details_box_display] = "HIDE"
    else
      session[:forum_details_box_display] = "SHOW"
    end
    
    respond_to do |format|
      format.html { 
        index
      }
      format.js  { do_rjs_toggle_forum_details_box }
    end
  end
  
  private
  
  def do_rjs_toggle_forum_details_box 
    render :update do |page|
      page.replace "forum_details_area", 
        :partial => "show_hide_forum_details"
      if session[:forum_details_box_display] == "HIDE"
        page.visual_effect :blind_up, :forum_details, :duration => 0.5
      else
        page.visual_effect :blind_down, :forum_details, :duration => 1
      end
    end
  end
end