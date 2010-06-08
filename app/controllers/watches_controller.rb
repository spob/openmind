class WatchesController < ApplicationController
  helper :idea_action, :forums, :products
  before_filter :login_required, :except => [ :create_product_watch_from_check_for_update ]
  cache_sweeper :forums_sweeper, :only => [ :create_forum_watch,
  :destroy_forum_watch
  ]
  
  verify :method => :post, :only => [:create, :create_from_show, :create_topic_watch ],
  :redirect_to =>{ :controller => 'ideas', :action => :index }
  verify :method => :put, :only => [ :update ],
  :redirect_to => { :controller => 'ideas', :action => :list }
  verify :method => :delete, :only => [ :destroy, :destroy_topic_watch ],
  :redirect_to => { :controller => 'ideas', :action => :list }
  
  # collection routes apparently can't take additonal parameters other than
  # id... so, a bit of a kludge, if we can't pass a from parameter to indicate
  # whether the action was originated from the list page or the show page, I
  # added another action to indicate the difference
  def create_from_show
    create "show"  
  end
  
  def create_product_watch_from_check_for_update
    if logged_in?
      create_product_watch
    else      
      flash[:notice] = 'You must be logged in to OpenMind in order to put a watch on a product'
      session[:return_to] = params[:from]
      redirect_to :controller => '/account', :action => 'login'
    end
  end
  
  def create_product_watches
    release_ids = params[:releases]
    if release_ids
      added = false
      release_ids.split(",").collect{|r| r.split("|").first}.each do |release_id|
        release = Release.find_by_id(release_id)
        if release
          unless release.product.watchers.include? current_user
            release.product.watchers << current_user
            added = true
          end
        else
          flash[:error] = "Unknown release id #{release_id}."
        end
      end
      if flash[:error].nil?
        if added
          flash[:notice] = "All of your products are now being watched."
        else
          flash[:error] = "No watches added...all of your products are already being watched."
        end
      end
    end
    redirect_to check_for_updates_releases_path(:releases => params[:releases], :serial_number => params[:serial_number])
  end
  
  def create_product_watch
    begin
      @product = Product.find(params[:id])
      
      @product.watchers << current_user unless @product.watchers.include? current_user
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to add watch to invalid product #{params[:id]}")
      flash[:error] = "Attempted to add watch to invalid product"
      # #list
      
      respond_to do |format|
        format.html { redirect_to product_path(@product) }
        format.js  { do_product_action   }
      end
      return false
    else
      flash[:notice] = "Product '#{@product.name}' is being watched."
      
      respond_to do |format|
        format.html { redirect_to product_path(@product) }
        format.js  { do_product_action   }
      end
    end
  end
  
  def create_forum_watch
    begin
      @forum = Forum.find(params[:id])
      
      unless @forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
        redirect_to redirect_path_on_access_denied(current_user)
      end
      
      @forum.watchers << current_user unless @forum.watchers.include? current_user
      @forum.watch_all_topics current_user
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to add watch to invalid forum #{params[:id]}")
      flash[:error] = "Attempted to add watch to invalid forum"
      # #list
      
      respond_to do |format|
        format.html {render forum_path(@forum) }
        format.js  { do_forum_action   }
      end
      return false
    else
      flash[:notice] = "Forum '#{@forum.name}' is being watched."
      
      respond_to do |format|
        format.html {redirect_to forum_path(@forum) }
        format.js  { do_forum_action }  
      end        
    end
  end
  
  def create_topic_watch
    begin
      @topic = Topic.find(params[:id])
      
      unless @topic.forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
        redirect_to redirect_path_on_access_denied(current_user)
      end
      
      @topic.watchers << current_user unless @topic.watchers.include? current_user
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to add watch to invalid topic #{params[:id]}")
      flash[:notice] = "Attempted to add watch to invalid topic"
      # #list
      
      respond_to do |format|
        format.html {render topic_path(@topic) }
        format.js  { do_topic_action   }
      end
      return false
    else
      flash[:notice] = "Topic '#{@topic.title}' is being watched."
      
      respond_to do |format|
        format.html {redirect_to topic_path(@topic) }
        format.js  { do_topic_action }  
      end        
    end
  end
  
  # Create idea watch
  def create from="list"
    begin
      @idea = Idea.find(params[:id])
      @idea.watchers << current_user unless @idea.watchers.include? current_user
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to add watch to invalid idea #{params[:id]}")
      flash[:notice] = "Attempted to add watch to invalid idea"
      # #list
      
      respond_to do |format|
        format.html {render :controller => 'ideas', :action => 'list' }
        format.js  { do_idea_action from  }
      end
      return false
    else
      flash[:notice] = "Idea number #{@idea.id} is being watched."
      
      respond_to do |format|
        format.html {redirect_to :controller => 'ideas', :action => 'show', :id  => @idea }
        format.js  { do_idea_action  from }      
      end 
    end
  end
  
  def destroy
    begin
      @idea = Idea.find(params[:id])
      @idea.watchers.delete(current_user)
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to remove watch from invalid idea #{params[:id]}")
      flash[:error] = "Attempted to remove watch from invalid idea"
      # #list
      respond_to do |format|
        format.html {render :controller => 'ideas', :action => 'list' }
        format.js  { do_idea_action   }
      end
      return false
    else
      flash[:notice] = %(Watch removed from Idea number #{@idea.id}.)
      
      respond_to do |format|
        format.html {redirect_to :controller => 'ideas', :action => 'show', :id  => @idea }
        format.js  { do_idea_action params[:from]  }
      end      
    end 
  end
  
  def destroy_forum_watch
    begin
      @forum = Forum.find(params[:id])
      
      unless @forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
        redirect_to redirect_path_on_access_denied(current_user)
      end
      
      @forum.watchers.delete(current_user)
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to remove watch from invalid forum #{params[:id]}")
      flash[:error] = "Attempted to remove watch from invalid forum"
      # #list
      respond_to do |format|
        format.html {redirect_to forum_path(@forum) }
        format.js  { do_forum_action   }
      end
      return false
    else
      flash[:notice] = %(Watch removed from forum '#{@forum.name}')
      
      respond_to do |format|
        format.html {redirect_to forum_path(@forum) }
        format.js  { do_forum_action  }
      end      
    end 
  end
  
  def destroy_product_watch
    begin
      @product = Product.find(params[:id])
      
      @product.watchers.delete(current_user)
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to remove watch from invalid product #{params[:id]}")
      flash[:error] = "Attempted to remove watch from invalid product"
      # list
      respond_to do |format|
        format.html { redirect_to product_path(@product) }
        format.js  { do_product_action   }
      end
      return false
    else
      flash[:notice] = %(Watch removed from product '#{@product.name}')
      
      respond_to do |format|
        format.html { redirect_to product_path(@product) }
        format.js  { do_product_action   }
      end
    end
  end
  
  def destroy_topic_watch
    begin
      @topic = Topic.find(params[:id])
      
      unless @topic.forum.can_see? current_user or prodmgr?
        flash[:error] = ForumsController.flash_for_forum_access_denied(current_user)
        redirect_to redirect_path_on_access_denied(current_user)
      end
      
      @topic.watchers.delete(current_user)
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to remove watch from invalid topic #{params[:id]}")
      flash[:notice] = "Attempted to remove watch from invalid topic"
      # #list
      respond_to do |format|
        format.html {render forums_path }
        format.js  { do_topic_action   }
      end
      return false
    else
      flash[:notice] = %(Watch removed from topic '#{@topic.title}')
      
      respond_to do |format|
        format.html {redirect_to topic_path(@topic) }
        format.js  { do_topic_action  }
      end      
    end 
  end
  
  private
  
  def redirect_path_on_access_denied user
    return forums_path unless user == :false
    return url_for(:controller => 'account', :action => 'login', :only_path => true) if user == :false
  end
  
  def do_idea_action from="list"
    render :update do |page|
      page.replace_html :flash_notice, flash_notice_string(flash[:notice]) 
      page.replace_html :flash_error,  flash_error_string(flash[:error])
      flash[:notice].nil? ? (page.hide :flash_notice) : (page.show :flash_notice)
      flash[:error].nil? ? (page.hide :flash_error) : (page.show :flash_error)
      flash.discard
      page.replace "action_buttons#{@idea.id.to_s}", 
      :partial => "ideas/list_actions", 
      :object => @idea,
      :locals => { :from => from}
    end
  end
  
  def do_topic_action
    render :update do |page|
      page.replace_html :flash_notice, flash_notice_string(flash[:notice]) 
      page.replace_html :flash_error,  flash_error_string(flash[:error])
      page.replace_html "topic_watchers#{@topic.id.to_s}", @topic.watchers.size
      flash[:notice].nil? ? (page.hide :flash_notice) : (page.show :flash_notice)
      flash[:error].nil? ? (page.hide :flash_error) : (page.show :flash_error)
      flash.discard
      page.replace "action_buttons#{@topic.id.to_s}", 
      :partial => "forums/topic_action", 
      :object => @topic
    end
  end
  
  def do_forum_action
    render :update do |page|
      page.replace_html :flash_notice, flash_notice_string(flash[:notice]) 
      page.replace_html :flash_error,  flash_error_string(flash[:error])
      flash[:notice].nil? ? (page.hide :flash_notice) : (page.show :flash_notice)
      flash[:error].nil? ? (page.hide :flash_error) : (page.show :flash_error)
      flash.discard
      page.replace "action_buttons#{@forum.id.to_s}", 
      :partial => "forums/forum_action", 
      :object => @forum
    end
  end
  
  def do_product_action
    render :update do |page|
      page.replace_html :flash_notice, flash_notice_string(flash[:notice])
      page.replace_html :flash_error,  flash_error_string(flash[:error])
      flash[:notice].nil? ? (page.hide :flash_notice) : (page.show :flash_notice)
      flash[:error].nil? ? (page.hide :flash_error) : (page.show :flash_error)
      flash.discard
      page.replace "action_buttons_#{@product.id.to_s}",
      :partial => "products/product_action",
      :object => @product
    end
  end
end
