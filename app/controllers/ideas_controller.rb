class IdeasController < ApplicationController
  helper :idea_action
  helper_method :tab_body_partial
  before_filter :login_required, :except => [:rss]
  access_control [:new, :edit, :create, :update, :destroy] => 'prodmgr | voter'

  def tag_cloud
    @tags = Idea.tag_counts
  end
  
  def self.view_types
    @@view_types
  end

  # Build an rss feed
  def rss
    render_rss_feed_for Idea.find(:all, :order => 'created_at DESC',
      :limit => 10), {
      :feed => {
        :title => 'OpenMind New Ideas',
        :link => url_for(:controller => 'ideas', :action => 'list', :only_path => false),
        :pub_date => :created_at
      },
      :item => {
        :title => :title,
        :description => :formatted_description,
        :link => Proc.new{|idea| url_for(:controller => 'ideas',
            :action => 'show', :id => idea.id)}
      }
    }
  end
 
  def index
    list
    render :action => 'list' unless request.xhr?
  end
    
  def preview
    render :layout => false
  end

  verify :method => :post, 
    :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }

  def list    
    session[:idea_search_box_display] ||= "HIDE"
    session[:idea_view_type] = params[:view_type] unless params[:view_type].nil?
    session[:idea_product_filter] = params[:product] unless params[:product].nil?
    session[:idea_release_filter] = params[:release] unless params[:release].nil?
    # note I test if params[:product].nil? because, if that's true, we're navigating
    # to this page from somewhere else, in case remember what it was before
    session[:title_filter] = params[:title_lookup] unless params[:product].nil?
    session[:author_filter] = params[:author] unless params[:product].nil?
    
    session[:idea_view_type] ||= "all"
    session[:idea_product_filter] ||= 0
    session[:idea_release_filter] ||= 0
    
    filter_properties = {
      :product_filter => session[:idea_product_filter],
      :release_filter => session[:idea_release_filter],
      :title_filter => session[:title_filter],
      :author_filter => session[:author_filter]        
    }
    case session[:idea_view_type]
    when "my_ideas"
      @ideas = Idea.list_my_ideas params[:page], current_user,
        filter_properties
    when "voted_ideas"
      @ideas = Idea.list_voted_ideas params[:page], current_user,
        filter_properties
    when "commented_ideas"
      @ideas = Idea.list_commented_ideas params[:page], current_user,
        filter_properties
    when "unread_comments"
      @ideas = Idea.list_unread_comments params[:page], current_user,
        filter_properties
    when "watched"
      @ideas = Idea.list_watched_ideas params[:page], current_user,
        filter_properties
    when "unread"
      @ideas = Idea.list_unread_ideas params[:page], current_user,
        filter_properties
    when "most_votes"
      @ideas = Idea.list_most_votes params[:page], current_user,
        filter_properties
    when "most_views"
      @ideas = Idea.list_most_views params[:page], current_user,
        filter_properties
    else
      @ideas = Idea.list params[:page], current_user,
        filter_properties
    end
    
    respond_to do |format|
      format.html {}
      format.js  { 
        render :update do |page|
          page.replace "filtermenu", :partial => "filter_tabs"
          page.replace "data", :partial => "ideas_table"
          page.replace_html :flash_notice, flash_notice_string(flash[:notice]) 
          page.replace_html :flash_error,  flash_error_string(flash[:error])
          flash[:notice].nil? ? (page.hide :flash_notice) : (page.show :flash_notice)
          flash[:error].nil? ? (page.hide :flash_error) : (page.show :flash_error)
          flash.discard
        end
      }
    end
  end
  
  def tag
    @ideas = Idea.paginate_list(Idea.find_tagged_with(params[:id]), 
      params[:page], 
      current_user.row_limit)
    session[:idea_view_type] = "tags"
    render :action => 'list'
  end
  
  def jump_to
    redirect_to :action => :show, :id => params[:goto_id]
  end

  def show
    begin
      @idea = Idea.find(params[:id])
      session[:selected_tab] = params[:selected_tab] if !params[:selected_tab].nil?
      session[:selected_tab] = "DETAILS" if session[:selected_tab] == "VOTES" && @idea.votes.empty?
      session[:selected_tab] = "DETAILS" if session[:selected_tab] == "COMMENTS" && @idea.comments.empty?
      session[:selected_tab] ||= "DETAILS"
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "No such idea '#{params[:id]}'"
      redirect_to :controller => 'ideas', :action => 'index'
    else
      mark_as_read @idea
    end
  end

  def new
    @idea ||= Idea.new
  end

  def create
    TagList.delimiter = " "
    @idea = Idea.new(params[:idea])
    @idea.user_id = current_user.id
    # author should watch the idea by default
    @idea.watchers << current_user
    if @idea.save
      # also createa  user read record so it doesn't show up as an unread record
      mark_as_read @idea
      
      flash[:notice] = "Idea #{@idea.id} was successfully created."
      redirect_to :action => 'index'
    else
      new
      render :action => 'new'
    end
  end

  def edit
    @idea = Idea.find(params[:id])
    authorize_edit @idea
  end

  def  filtered_product_select
    @releases = [["Not scheduled", 0]]
    for release in Release.find_all_by_product_id(params["product_id"], :order => "version ASC")
      @releases << ["#{release.version} (#{release.release_status.description})", release.id]
    end
    @releases 
    #    Regular way to do it
    #    @releases =  Release.find_all_by_product_id(params["product_id"], :order => "version ASC")
    render :partial => 'options'
  end

  def update
    TagList.delimiter = " "
    params[:idea][:release_id] = nil if !params[:idea].nil? and params[:idea][:release_id] == "0"
    @idea = Idea.find(params[:id])
    original_idea = Idea.find(@idea.id, :readonly => true)
    authorize_edit @idea
    if @idea.update_attributes(params[:idea])
      # did the user change the product, leaving the release invalid?
      @idea.update_attributes(:release_id => nil) if !@idea.release.nil? and @idea.release.product.id != @idea.product.id
      # do any merged ideas need to have their releases updated as well
      if !@idea.release.nil?
        for merged_idea in @idea.merged_ideas
          merged_idea.update_attributes(:release_id => @idea.release.id) if merged_idea.release.nil? and merged_idea.product.id == @idea.product.id
        end
      end
      
      EmailNotifier.deliver_idea_change_notifications(@idea, 
        generate_change_log(original_idea, @idea)) if !@idea.watchers.empty?
      
      flash[:notice] = "Idea number #{@idea.id} was successfully updated."      
      redirect_to :action => 'show', :id => @idea.id
    else
      render :action => 'edit'
    end
  end

  def destroy
    idea = Idea.find(params[:id])
    id = idea.id
    idea.destroy
    flash[:notice] = "Idea number #{id} was successfully deleted."
    redirect_to :action => 'index'
  end
  
  def titles_for_lookup
    @titles = Idea.find(:all, :select => 'title')
    @headers['content-type'] = 'text/javascript'
    render :layout => false
  end

  
  #  THESE ARE NEW 
    
  def select_details
    session[:selected_tab] = "DETAILS"
    render_tab_bodies
  end


  def select_comments
    session[:selected_tab] = "COMMENTS"
    render_tab_bodies
  end

  def select_votes
    session[:selected_tab] = "VOTES"
    render_tab_bodies
  end  
  
  def tab_body_partial
    partial = ""
    if session[:selected_tab] == "COMMENTS"
      partial = "comments/comments"
    elsif session[:selected_tab] == "VOTES"
      partial = "votes/votes"
    else   # Details
      partial = "ideas/idea_details"
    end    
    partial
  end
  
  def toggle_search_box
    if session[:idea_search_box_display] == "HIDE"
      session[:idea_search_box_display] = "SHOW"
    else
      session[:idea_search_box_display] = "HIDE"
    end
    
    respond_to do |format|
      format.html { 
        index
      }
      format.js  { do_rjs_toggle_search_box }
    end
  end
  
  private
  
  def do_rjs_toggle_search_box 
    render :update do |page|
      page.replace "search_area", 
        :partial => "show_hide_search_box_button"
      if session[:idea_search_box_display] == "HIDE"
        page.visual_effect :blind_up, :idea_search, :duration => 0.5
      else
        page.visual_effect :blind_down, :idea_search, :duration => 1
      end
    end
  end
  
  def render_tab_bodies
    @idea = Idea.find(params[:id])
    respond_to do |format|
      format.html { redirect_to :controller => 'ideas', :action => 'show', :id  => @idea }
      format.js  {
        render :update do |page|
          page.replace "tabBody",  :partial => tab_body_partial, :object => @idea
          page.replace "tabs",  :partial => "tabs", :object => @idea
          page.replace_html :flash_notice, flash_notice_string(flash[:notice]) 
          page.replace_html :flash_error,  flash_error_string(flash[:error])
          flash[:notice].nil? ? (page.hide :flash_notice) : (page.show :flash_notice)
          flash[:error].nil? ? (page.hide :flash_error) : (page.show :flash_error)
          flash.discard
        end
      }
    end    
  end
  
  def authorize_edit idea
    if !can_edit_idea? idea
      flash[:notice] = "You are not authorized to edit idea number #{idea.id}"      
      redirect_to :action => 'show', :id => idea.id
    end
  end
  
  def set_can_delete
    @can_delete = voter?
  end
  
  def mark_as_read(idea)
    idea.update_attribute(:view_count, idea.view_count + 1)
    user_idea_read = idea.user_idea_reads.find(:first, :conditions => ["user_id = ?",
        current_user.id])
    if user_idea_read.nil?
      user_idea_read = UserIdeaRead.new(:user_id => current_user.id, :last_read => Time.now)
      idea.user_idea_reads << user_idea_read
    elsif
      user_idea_read.update_attributes(:last_read => Time.now)
    end
  end
  
  @@change_loggers = nil
  
  def generate_change_log before_idea, after_idea
    @@change_loggers ||= [ 
      IdeaTitleChangeLog.new, 
      IdeaDescriptionChangeLog.new,
      IdeaProductChangeLog.new,
      IdeaReleaseChangeLog.new,
    ]
    change_messages = []
    for change_logger in @@change_loggers
      change_messages << change_logger.calc_change_log(before_idea, after_idea)
    end
    change_messages.compact
  end
  
  class IdeaTitleChangeLog
    def calc_change_log before_idea, after_idea
      if before_idea.title != after_idea.title
        return "Title was updated to '#{after_idea.title}'"
      end
    end
  end
  
  class IdeaDescriptionChangeLog
    def calc_change_log before_idea, after_idea
      if before_idea.description != after_idea.description
        return "Description was updated"
      end
    end
  end
  
  class IdeaProductChangeLog
    def calc_change_log before_idea, after_idea
      if before_idea.product.id != after_idea.product.id
        return "Product was updated from '#{before_idea.product.name}' to '#{after_idea.product.name}'"
      end
    end
  end
  
  class IdeaReleaseChangeLog
    def calc_change_log before_idea, after_idea
      if before_idea.release.nil? and !after_idea.release.nil?
        return "Idea was scheduled for release #{after_idea.release.version}"
      elsif !before_idea.release.nil? and after_idea.release.nil?
        return "Idea was previously scheduled for release #{before_idea.release.version} and is now unscheduled"
      elsif !before_idea.release.nil? and !after_idea.release.nil? and
          before_idea.release.id != after_idea.release.id
        return "Idea was previously scheduled for release #{before_idea.release.version} and is now scheduled for release #{after_idea.release.version}"
      end
    end
  end
end
