class CommentsController < ApplicationController
  helper :idea_action
  
  before_filter :login_required
  access_control [:edit, :update, :destroy] => 'prodmgr | voter'
 
  def index
    @comment_pages, @comments = paginate :comments, :per_page => 10
  end

  def preview
    render :layout => false
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)c/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to =>{ :controller => 'ideas', :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :controller => 'ideas', :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :controller => 'ideas', :action => :index }

  def show
    @comment = IdeaComment.find(params[:id])
  end

  def new
    if params[:type] == 'idea'
      @idea = Idea.find(params[:id]) 
      @comment ||= IdeaComment.new
    else
      @topic = Topic.find(params[:id]) 
      @comment ||= TopicComment.new
    end
  end

  def create
    if params[:type] == 'Idea'
      create_idea_comment
    else 
      create_topic_comment
    end
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
      redirect_to :controller => 'ideas', :action => 'show', :id => @idea, :selected_tab => "COMMENTS"
    else
      new
      render :action => 'new'
    end
  end

  def create_topic_comment
    @topic = Topic.find(params[:id])
    @comment = TopicComment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.topic_id = @topic.id
    if params[:watch] == 'yes'
    	@topic.watchers << current_user
    end
    if @topic.save and @comment.save
      flash[:notice] = "Comment for topic '#{@topic.title}' was successfully created."
      redirect_to topic_path(@topic.id)
    else
      new
      render :action => 'new'
    end
  end
end
