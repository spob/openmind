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
  end
  
  def index
    @forums = Forum.list params[:page], (current_user == :false ? 10 : current_user.row_limit)
  end

  def create
    params[:forum][:mediator_ids] ||= []
    params[:forum][:group_ids] ||= []
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
    @forum = Forum.find(params[:id])
    if @forum.update_attributes(params[:forum])
      flash[:notice] = "Forum '#{@forum.name}' was successfully updated."
      redirect_to forums_path
    else
      render :action => :edit
    end
  end
  
  def search
  	@hits = {}
  	session[:forums_search] = params[:search]
  	Topic.find_with_index(params[:search]).each do |topic|
  		@hits[topic.id] = TopicHit.new(topic, true)
  	end
  	TopicComment.find_with_index(params[:search]).each do |comment|
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

  def destroy
    forum = Forum.find(params[:id])
    name = forum.name
    forum.destroy
    flash[:notice] = "Forum #{name} was successfully deleted."
    redirect_to forums_url
  end
end