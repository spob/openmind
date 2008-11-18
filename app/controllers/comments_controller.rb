class CommentsController < ApplicationController  
  helper :ideas
  
  before_filter :login_required
  access_control [:edit, :update, :destroy] => 'prodmgr | voter'
   
  # GETs should be safe (see
  # http://www.w3.org/2001/tag/doc/whenToUseGet.html)c/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
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
      flash[:notice] = "Endorsement has been removed"
      redirect_to topic_path(@comment.topic.id, :anchor => @comment.id)
      return
    end
    @comment.endorser = nil
    @comment.save!
    flash[:notice] = "Comment endorsement has been removed"
    redirect_to topic_path(@comment.topic.id, :anchor => @comment.id)
  end

  def edit
    @comment = Comment.find(params[:id])
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
  
  private

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
    # touch counter exists to force an update on the topic so that updated_at
    # column is updated, so that topics are sorted properly
    @topic.touch_counter = @topic.touch_counter + 1
    
    @comment = TopicComment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.topic_id = @topic.id
    @comment.endorser = current_user if @topic.forum.mediators.include? current_user
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
end
