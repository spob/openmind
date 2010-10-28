class TopicsController < ApplicationController
  before_filter :fetch_topic, :only => [:show]
  before_filter :login_required, :only => [:show], :if => :must_login 
  before_filter :login_required, :except => [:index, :show, :search]
  cache_sweeper :topics_sweeper, :only => [ :create, :update, :destroy, :toggle_status ]
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :rate ],
  :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update, :toggle_status ],
  :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
  :redirect_to => { :action => :index }
  
  def index
    redirect_to forums_path
  end
  
  def new
    @forum ||= Forum.find(params[:forum_id])
    
    unless @forum.can_see? current_user or prodmgr?
      flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
      redirect_to redirect_path_on_access_denied(current_user)
    end
    
    if @forum.restrict_topic_creation and !@forum.mediator? current_user
      flash[:error] = 'You are not able to create new topics in this forum'
      redirect_to forum_path(@forum)
    end
    
    @topic ||= Topic.new(:forum => @forum)
    @comment ||= TopicComment.new(:topic => @topic)
  end
  
  def create    
    forum_id = params[:forum_id]
    forum = Forum.find(forum_id)
    if forum.restrict_topic_creation and !forum.mediator? current_user
      flash[:error] = 'You are not able to create new topics in this forum'
      redirect_to forum_path(forum)
      return
    end
    @topic = Topic.new(params[:topic])
    @topic.forum_id = forum_id
    @topic.user = current_user
    if @topic.save   
      @topic.add_user_read(current_user)
      comment = TopicComment.new(
                                 :user_id => current_user.id,
                                 :body => @topic.comment_body)
      comment.endorser = current_user if @topic.forum.mediators.include? current_user
      @topic.comments << comment
      
      #      @topic = Topic.find(@topic.id)
      for user in @topic.forum.watchers
        @topic.watchers << user unless @topic.watchers.include? user
      end
      
      tw = TopicWatch.find_by_user_id_and_topic_id(current_user, @topic)
      @topic.watchers << current_user if tw.nil?
      @topic.save!
      if params[:attach] == 'yes'
        redirect_to attach_comment_path(comment)
      else
        flash[:notice] = "Topic #{@topic.title} was successfully created."
        redirect_to topic_path(@topic.id)
      end
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
      unless @topic.forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
        redirect_to redirect_path_on_access_denied(current_user)
      end
      if logged_in? and @topic.unread_comment?(current_user)
        expire_fragment(%r{forums/list_forums.user_id=#{current_user.id}})
      end
      @topic.add_user_read(current_user).save unless current_user == :false
    end
  end
  
  def destroy
    topic = Topic.find(params[:id])
    forum = topic.forum
    title = topic.title
    
    # A bit bizarre, but if I don't clear the comments first, I get a stale object exception
    topic.comments.clear
    topic.save
    Topic.destroy(topic.id)
    
    flash[:notice] = "Topic '#{title}' was successfully deleted."
    redirect_to forum_path(forum)
  end
  
  def edit
    @topic = Topic.find(params[:id])
    
    unless @topic.forum.can_edit? current_user or prodmgr?
      flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
      redirect_to redirect_path_on_access_denied(current_user)
    end
  end
  
  def update
    @topic = Topic.find(params[:id])
    unless params[:topic][:owner_id].nil? or params[:topic][:owner_id].empty?
      # was owner updated? If so, make sure they are watching this topic
      @user = User.find params[:topic][:owner_id]
      # Add watcher unless owner is already watching or the owner did not change
      @topic.watchers << @user unless @topic.watchers.include? @user or @topic.owner == @user
    end
    
    unless @topic.forum.can_edit? current_user or prodmgr?
      flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
      redirect_to redirect_path_on_access_denied(current_user)
    end
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Topic '#{@topic.title}' was successfully updated."
      redirect_to topic_path(@topic)
    else
      render :action => :edit
    end
  end
  
  def search
    @forum = Forum.find(params[:forum_id])
    hits = {}
    @hits = []
    session[:forums_search] = params[:search]
    
    # solr barfs if search string starts with a wild card...so strip it out
#    params[:search] = StringUtils.sanitize_search_terms params[:search]
    begin
#      search_results = Topic.find_by_solr(params[:search], :scores => true)
      search_results = params[:search].blank? ? [] : Topic.search(params[:search], :retry_stale => true, :limit => 500)
    rescue RuntimeError => e
      flash[:error] = "An error occurred while executing your search. Perhaps there is a problem with the syntax of your search string."
      logger.error(e)
    else
      # not sure why this is necessary
      #      flash[:error] = nil
      flash.discard
      
      if search_results.nil?
        redirect_to forum_path(@forum)
        return
      end
      search_results.each do |topic|
        hits[topic.id] = TopicHit.new(topic, true, 1) if topic.forum.can_see?(current_user) or prodmgr?
      end
#      TopicComment.find_by_solr(params[:search], :scores => true).docs.each do |comment|
      (params[:search].blank? ? [] : TopicComment.search(params[:search], :retry_stale => true, :limit => 500)).each do |comment|
        if (comment.topic.forum.can_see?(current_user) or prodmgr?) and
         (!comment.private or comment.topic.forum.mediators.include? current_user)
          # first see if topic hit already exists
          topic_hit = hits[comment.topic.id]
          if topic_hit.nil?
            hit = TopicHit.new(comment.topic, false, 1)
            hit.comments << comment
            hits[comment.topic.id] = hit
          else
            topic_hit.comments << comment
            topic_hit.score = comment.solr_score if topic_hit.score < 1
          end
        end
      end
      @hits = hits.values.find_all{ |hit| hit.topic.forum == @forum }
      TopicHit.normalize_scores(@hits)
    end
  end
  
  def toggle_status
    @topic = Topic.find(params[:id])
    @topic.open_status = !@topic.open_status
    @topic.save!
    flash[:notice] = "Topic has been marked as #{(@topic.open_status ? "open" : "closed")}"
    redirect_to topic_path(@topic)
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
  
  def rate
    @topic = Topic.find(params[:id])
    @topic.rate(params[:stars], current_user, params[:dimension])
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}topic-#{@topic.id}"
    render :update do |page|
      page.replace_html id, ratings_for(@topic, :wrap => false, :dimension => params[:dimension])
      page.visual_effect :highlight, id
    end
  end
  
  
  private
  
  def fetch_topic    
    @topic = Topic.find(params[:id])
  end
  
  def must_login
    (!@topic.forum.public? and current_user == :false)
  end
  
  def redirect_path_on_access_denied user
    return forums_path unless user == :false
    return url_for(:controller => 'account', :action => 'login', :only_path => true) if user == :false
  end
  
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