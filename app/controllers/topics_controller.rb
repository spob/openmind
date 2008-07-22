class TopicsController < ApplicationController
  before_filter :login_required

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
    forum = Forum.find(params[:forum_id])
    @topic = Topic.new(:forum => forum)
    @comment = TopicComment.new(:topic => @topic)
  end

  def create
    forum_id = params[:forum_id]
    @topic = Topic.new(params[:topic])
    @topic.forum_id = forum_id
    @topic.user = current_user
    @topic.save
    
    @topic.comments.build(
      :user_id => current_user.id,
      :body => @topic.comment_body)
    @topic.add_user_read(current_user)
    @topic.watchers << current_user
    
    tw = TopicWatch.find_by_user_id_and_topic_id(current_user, @topic)
    @topic.watchers << current_user if tw.nil?
    
    for user in @topic.forum.watchers
      @topic.watchers << user unless topic.watchers.include? user
    end
  
    if @topic.save
      flash[:notice] = "Topic #{@topic.title} was successfully created."
      redirect_to forum_path(forum_id)
    else
      @forum = Forum.find(forum_id)
      render :action => 'new', :forum_id => forum_id
    end
  end

  def preview
    render :layout => false
  end
  
  def show
    @topic = Topic.find(params[:id])
    @topic.add_user_read(current_user).save
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
end