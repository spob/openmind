class TopicsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }
  
  def index
    redirect_to forums_path
  end
  
  def new
    @forum ||= Forum.find(params[:forum_id])
    
    unless @forum.can_see? current_user or prodmgr?
      flash[:error] = ForumsController.forum_access_denied(current_user)
      redirect_to forums_path
      return
    end
    
    @topic ||= Topic.new(:forum => @forum)
    @comment ||= TopicComment.new(:topic => @topic)
  end

  def create
    forum_id = params[:forum_id]      
    @topic = Topic.new(params[:topic])
    @topic.forum_id = forum_id
    @topic.user = current_user
    if @topic.save   
      @topic.comments << TopicComment.new(
        :user_id => current_user.id,
        :body => @topic.comment_body)
      @topic.add_user_read(current_user)
    
      #      @topic = Topic.find(@topic.id)
      for user in @topic.forum.watchers
        @topic.watchers << user unless @topic.watchers.include? user
      end
        
      tw = TopicWatch.find_by_user_id_and_topic_id(current_user, @topic)
      @topic.watchers << current_user if tw.nil?
      @topic.save!
      flash[:notice] = "Topic #{@topic.title} was successfully created."
      redirect_to forum_path(forum_id)
    else
      @forum = Forum.find(forum_id)
      new
      render :action => 'new', :forum_id => forum_id
    end
  end

  def preview
    render :layout => false
  end
  
  def show
    session[:forums_search] = nil
    Topic.transaction do
      @topic = Topic.find(params[:id])
      unless @topic.forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.forum_access_denied(current_user)
        redirect_to forums_path
      end
      @topic.add_user_read(current_user).save unless current_user == :false
    end
  end

  def destroy
    topic = Topic.find(params[:id])
    forum = topic.forum
    title = topic.title
    topic.destroy
    flash[:notice] = "Topic '#{title}' was successfully deleted."
    redirect_to forum_path(forum)
  end

  def edit
    @topic = Topic.find(params[:id])
    
    unless @topic.forum.can_see? current_user or prodmgr?
      flash[:error] = ForumsController.forum_access_denied(current_user)
      redirect_to forums_path
    end
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Topic '#{@topic.title}' was successfully updated."
      redirect_to forum_path(@topic.forum)
    else
      render :action => :edit
    end
  end
  
  def search
    @forum = Forum.find(params[:forum_id])
    hits = {}
    session[:forums_search] = params[:search]
    Topic.find_with_index(params[:search]).each do |topic|
      hits[topic.id] = TopicHit.new(topic, true) if topic.forum.can_see?(current_user) or prodmgr?
    end
    TopicComment.find_with_index(params[:search]).each do |comment|
      if comment.topic.forum.can_see?(current_user) or prodmgr?
        # first see if topic hit already exists
        topic_hit = hits[comment.topic.id]
        if topic_hit.nil?
          hit = TopicHit.new(comment.topic, false)
          hit.comments << comment 
          hits[comment.topic.id] = hit
        else
          topic_hit.comments << comment
        end	
      end
    end
    @hits = hits.values.find_all{ |hit| hit.topic.forum == @forum }
  end
  
  def toggle_topic_details_box
    @topic = Topic.find(params[:id])
    if session[:topic_details_box_display] == "SHOW"
      session[:topic_details_box_display] = "HIDE"
    else
      session[:topic_details_box_display] = "SHOW"
    end
    
    respond_to do |format|
      format.html { 
        index
      }
      format.js  { do_rjs_toggle_topic_details_box }
    end
  end
  
  private
  
  def do_rjs_toggle_topic_details_box 
    render :update do |page|
      page.replace "topic_details_area", 
        :partial => "show_hide_topic_details"
      if session[:topic_details_box_display] == "HIDE"
        page.visual_effect :blind_up, :topic_details, :duration => 0.5
      else
        page.visual_effect :blind_down, :topic_details, :duration => 1
      end
    end
  end
end