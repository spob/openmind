class CommentsController < ApplicationController  
  helper :ideas
  before_filter :login_required
  access_control [:edit, :update, :destroy] => 'prodmgr | voter',
  [:promote_power_user] => 'mediator'
  cache_sweeper :comments_sweeper, :only => [ :create, :update, :destroy ]
  
  # GETs should be safe (see
  # http://www.w3.org/2001/tag/doc/whenToUseGet.html)c/whenToUseGet.html)
  verify :method => :post, :only => [:create,:promote_power_user ],
  :redirect_to =>{ :controller => 'ideas', :action => :index }
  verify :method => :put, :only => [ :update ],
  :redirect_to => { :controller => 'ideas', :action => :index }
  verify :method => :delete, :only => [ :destroy ],
  :redirect_to => { :controller => 'ideas', :action => :index }
  
  def index
    @comment_pages, @comments = paginate :comments, :per_page => 10
  end
  
  def preview
    render :layout => false
  end
  
  def show
    @comment = IdeaComment.find(params[:id])
  end
  
  def new
    if params[:type] == 'Idea'
      @idea = Idea.find(params[:id]) 
      @comment ||= IdeaComment.new
    else
      @topic = Topic.find(params[:id]) 
      @comment ||= TopicComment.new
      
      unless @topic.forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
        redirect_to redirect_path_on_access_denied(current_user)
      end
      unless @topic.can_add_comment? current_user
        flash[:error] = "You cannot add a comment to this topic"
        redirect_to topic_path(@topic)
      end
    end
  end
  
  def attach
    @comment = Comment.find(params[:id])   
    unless @comment.can_edit?(current_user, prodmgr?)
      flash[:error] = "You do not have priveleges to edit this comment"
      if @comment.class.to_s == 'TopicComment'
        redirect_to topic_path(@topic.id)
      else
        redirect_to :controller => 'ideas', :action => 'show', :id => @idea, 
        :selected_tab => "COMMENTS"
      end
    end
  end
  
  def create
    if params[:type] == 'Idea'
      create_idea_comment
    else 
      create_topic_comment
    end
  end
  
  def endorse
    @comment = TopicComment.find(params[:id])
    unless @comment.can_endorse? current_user
      flash[:error] = "Cannot endorse this comment"
      redirect_to topic_path(@comment.topic.id)
      return
    end
    @comment.endorser = current_user
    @comment.save!
    flash[:notice] = "Comment has been endorsed"
    redirect_to topic_path(@comment.topic.id, :anchor => @comment.id)
  end
  
  def unendorse
    @comment = TopicComment.find(params[:id])
    unless @comment.can_unendorse? current_user
      flash[:error] = "Cannot unendorse this comment"
      redirect_to topic_path(@comment.topic.id, :anchor => @comment.id)
      return
    end
    @comment.endorser = nil
    @comment.save!
    flash[:notice] = "Comment endorsement has been removed"
    redirect_to topic_path(@comment.topic.id, :anchor => @comment.id)
  end
  
  def privatize
    make_private params[:id], true
  end
  
  def publicize
    make_private params[:id], false
  end
  
  def edit
    @comment = Comment.find(params[:id])
    if @comment.class.to_s == 'TopicComment'
      unless @comment.topic.forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
        redirect_to redirect_path_on_access_denied(current_user)
      end
    end
  end
  
  def update
    @comment = Comment.find(params[:id])
    if @comment.update_attributes(params[:comment])
      flash[:notice] = 'Comment was successfully updated.'
      if @comment.class.to_s == "IdeaComment"
        redirect_to :controller => :ideas, :action => :show, :id => @comment.idea.id
      else
        redirect_to topic_path(@comment.topic.id)
      end
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    IdeaComment.find(params[:id]).destroy
    redirect_to comments_path
  end
  
  def promote_power_user
    comment = TopicComment.find(params[:id])
    if !comment.topic.mediator? current_user
      flash[:error] = "Only moderators can promote a power user"
    elsif comment.topic.forum.power_user? comment.user
      flash[:error] = "User is already a power user for this forum"
    else
      comment.topic.forum.power_user_group.users << comment.user
      comment.topic.forum.power_user_group.save
      flash[:notice] = "User has been promoted to a power user for this forum"
    end
    redirect_to topic_path(comment.topic.id, :anchor => comment.id)
  end
  
  private
  
  def redirect_path_on_access_denied user
    return forums_path unless user == :false
    return url_for(:controller => 'account', :action => 'login', :only_path => true) if user == :false
  end
  
  def create_idea_comment
    @idea = Idea.find(params[:id])
    @comment = IdeaComment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.idea_id = @idea.id
    if params[:watch] == 'yes'
      @idea.watchers << current_user
    end
    if @comment.save
      flash[:notice] = "Comment for idea number #{@comment.idea.id} was successfully created."
      if params[:attach] == 'yes'
        redirect_to attach_comment_path(@comment)
      else
        redirect_to :controller => 'ideas', :action => 'show', :id => @idea, 
        :selected_tab => "COMMENTS"
      end
    else
      new
      render :action => 'new'
    end
  end
  
  def create_topic_comment
    @topic = Topic.find(params[:id])
    unless @topic.can_add_comment? current_user
      flash[:error] = "You cannot add a comment to this topic"
      redirect_to topic_path(@topic)
      return
    end
    # touch counter exists to force an update on the topic so that updated_at
    # column is updated, so that topics are sorted properly
    @topic.touch_counter = @topic.touch_counter + 1
    
    @comment = TopicComment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.topic_id = @topic.id
    @comment.endorser = current_user if @topic.forum.mediators.include? current_user
    if params[:private] == 'yes'
      @comment.private = true
    end
    if params[:watch] == 'yes'
      @topic.watchers << current_user
    end
    if @topic.save and @comment.save
      flash[:notice] = "Comment for topic '#{@topic.title}' was successfully created."
      if params[:attach] == 'yes'
        redirect_to attach_comment_path(@comment)
      else
        redirect_to topic_path(@topic.id)
      end
    else
      new
      render :action => 'new'
    end
  end
  
  def make_private id, private
    @comment = TopicComment.find(id)
    unless @comment.topic.forum.mediators.include? current_user
      flash[:error] = "Cannot make this comment #{private ? "private" : "public"}"
      redirect_to topic_path(@comment.topic.id)
      return
    end
    @comment.private = private
    @comment.save!
    flash[:notice] = "Comment has been made #{private ? "private" : "public"}"
    redirect_to topic_path(@comment.topic.id, :anchor => @comment.id)
  end
end
