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
    
    comment = TopicComment.new(
      :user_id => current_user.id,
      :body=>@topic.comment_body)
    @topic.comments << comment
  
    if @topic.save
      flash[:notice] = "Topic #{@topic.title} was successfully created."
      redirect_to forum_path(forum_id)
    else
      @forum = Forum.find(forum_id)
      render :action => 'new', :forum_id => forum_id
    end
  end
end