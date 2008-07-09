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
end