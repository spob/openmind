require 'fastercsv'
require 'csv'

class IdeasController < ApplicationController
  helper :idea_action
  helper_method :tab_body_partial
  before_filter :login_required, :except => [:rss]
  access_control [:new, :edit, :create, :update, :destroy] => 'prodmgr | voter'
  
  verify :method => :post, 
  :only => [ :destroy, :create, :update ],
  :redirect_to => { :action => :list }
  
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
  
  def list    
    session[:idea_search_box_display] ||= "HIDE"
    session[:idea_view_type] = params[:view_type] unless params[:view_type].nil?
    session[:idea_view_type] = nil if params[:reset] == "yes" and session[:idea_view_type] == 'tags'
    session[:idea_product_filter] = params[:product] unless params[:product].nil?
    session[:idea_release_filter] = params[:release] unless params[:release].nil?
    session[:idea_tag_filter] = nil unless session[:idea_view_type] == 'tags'
    # note I test if params[:product].nil? because, if that's true, we're
    # navigating to this page from somewhere else, in case remember what it was
    # before
    session[:title_filter] = params[:title_lookup] unless params[:product].nil?
    session[:author_filter] = params[:author] unless params[:product].nil?
    
    session[:idea_view_type] ||= "all"
    session[:idea_product_filter] ||= 0
    session[:idea_release_filter] ||= 0
    
    filter_properties = {
      :product_filter => session[:idea_product_filter],
      :release_filter => session[:idea_release_filter],
      :title_filter => session[:title_filter],
      :author_filter => session[:author_filter],
      :tags_filter_ideas => Idea.find_tagged_with(session[:idea_tag_filter])
    }
    
    respond_to do |format|
      format.html {
        @ideas = fetch_ideas filter_properties, true
      }
      format.js  { 
        @ideas = fetch_ideas filter_properties, true
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
      format.csv {
        @ideas = fetch_ideas filter_properties, false
        
        response = ""
        csv = FasterCSV.new(response, :row_sep => "\r\n")
        cols = ["Idea #", "Title","Status","Votes","Product","Release"]
        csv << cols
        
        @ideas.each do |idea|
          cols = [idea.id, idea.title, idea.display_status, idea.votes.size,
          idea.product.name, idea.release.try(:name)]
          csv << cols
        end
        
        CsvUtils.setup_request_for_csv headers, request, "ideas.csv"
        render :text => response
        
        #        stream_csv do |csv|
        #          cols = ["Idea #", "Title","Status","Votes","Product","Release"]
        #          csv << cols
        #          @ideas.each do |idea|
        #            release = idea.release.version unless idea.release.nil?
        #            cols = [idea.id, idea.title, idea.display_status, idea.votes.size,
        #            idea.product.name, release]
        #            csv << cols
        #          end
        #        end  
        #    CsvUtils.setup_request_for_csv headers, request, "ideas.csv"
        #    render :text => response      
        #        }
      }
    end
  end
  
  def tag
    #    render :action => 'list'
    session[:idea_view_type] = "tags"
    session[:idea_tag_filter] = params[:id]
    redirect_to :action => :list
  end
  
  def jump_to
    redirect_to :action => :show, :id => params[:goto_id]
  end
  
  def show
    begin
      @idea = Idea.find(params[:id])
      set_selected_tab(@idea)
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "No such idea '#{params[:id]}'"
      redirect_to :controller => 'ideas', :action => 'index'
    else
      mark_as_read @idea
    end
  end
  
  def new_email_request
    @idea_email_request = IdeaEmailRequest.new
    @idea_email_request.idea = Idea.find(params[:idea_id])
    @idea_email_request.subject = "#{current_user.full_name} has forwarded you an OpenMind idea"
    @idea_email_request.cc_self = true
  end
  
  def create_email_request
    @idea_email_request = IdeaEmailRequest.new(params[:idea_email_request])
    @idea_email_request.user = current_user
    if @idea_email_request.save
      flash[:notice] = "Your request to email Idea #{@idea_email_request.idea.id} was recorded."
      redirect_to :action => 'show', :id => @idea_email_request.idea
    else
      render :action => 'new_email_request'
    end
    RunOncePeriodicJob.create(
                              :job => "IdeaEmailRequest.email_idea(#{@idea_email_request.id})")
  end
  
  def next
    ideas = Idea.next(params[:id])
    if ideas.empty?
      @idea = Idea.find(params[:id])
    else
      @idea = ideas.first
      mark_as_read @idea
    end
    set_selected_tab @idea
    render :action => 'show'
  end
  
  def previous
    ideas = Idea.previous(params[:id])
    if ideas.empty?
      @idea = Idea.find(params[:id])
    else
      @idea = ideas.first
      mark_as_read @idea
    end
    set_selected_tab @idea
    render :action => 'show'
  end
  
  def new
    @idea ||= Idea.new
  end
  
  def create
    #    params['idea'].each_pair {|key, value| puts "[#{key}] #{value}"}
    @idea = Idea.new(params[:idea])
    @idea.user_id = current_user.id
    # author should watch the idea by default
    @idea.watchers << current_user
    @idea.change_logs <<  IdeaChangeLog.new(:message => "Idea created", 
    :user => current_user
    #          :processed_at => Time.zone.now
    )
    if @idea.save
      # also create a user read record so it doesn't show up as an unread record
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
    params[:idea][:release_id] = nil if !params[:idea].nil? and params[:idea][:release_id] == "0"
    @idea = Idea.find(params[:id])
    original_idea = Idea.find(@idea.id, :readonly => true)
    original_idea.nondb_tag_list = original_idea.tag_list
    authorize_edit @idea
    if @idea.update_attributes(params[:idea])
      # convert to use fckedit if was previously using textiled
      @idea.update_attributes(:textiled => false) if @idea.textiled
      
      # did the user change the product, leaving the release invalid?
      @idea.update_attributes(:release_id => nil) if !@idea.release.nil? and @idea.release.product.id != @idea.product.id
      # do any merged ideas need to have their releases updated as well
      if !@idea.release.nil?
        for merged_idea in @idea.merged_ideas
          merged_idea.update_attributes(:release_id => @idea.release.id) if merged_idea.release.nil? and merged_idea.product.id == @idea.product.id
        end
      end
      
      generate_change_log(original_idea, @idea)
      
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
  
  #  def titles_for_lookup
  #    @titles = Idea.find(:all, :select => 'title')
  #    headers['content-type'] = 'text/javascript'
  #    render :layout => false
  #  end
  
  
  #  THESE ARE NEW
  
  def select_details
    session[:selected_tab] = "DETAILS"
    render_tab_bodies
  end
  
  def select_comments
    session[:selected_tab] = "COMMENTS"
    render_tab_bodies
  end
  
  def select_changes
    session[:selected_tab] = "CHANGES"
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
    elsif session[:selected_tab] == "CHANGES"
      partial = "ideas/idea_changes"
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
  
  def set_selected_tab idea    
    session[:selected_tab] = params[:selected_tab] if !params[:selected_tab].nil?
    session[:selected_tab] = "DETAILS" if session[:selected_tab] == "VOTES" && idea.votes.empty?
    session[:selected_tab] = "DETAILS" if session[:selected_tab] == "CHANGES" && idea.change_logs.empty?
    session[:selected_tab] = "DETAILS" if session[:selected_tab] == "COMMENTS" && idea.comments.empty?
    session[:selected_tab] ||= "DETAILS"
  end
  
  def fetch_ideas filter_properties, do_paginate
    case session[:idea_view_type]
      when "my_ideas"
      @ideas = Idea.list_my_ideas params[:page], current_user,
      filter_properties, do_paginate
      when "voted_ideas"
      @ideas = Idea.list_voted_ideas params[:page], current_user,
      filter_properties, do_paginate
      when "commented_ideas"
      @ideas = Idea.list_commented_ideas params[:page], current_user,
      filter_properties, do_paginate
      when "unread_comments"
      @ideas = Idea.list_unread_comments params[:page], current_user,
      filter_properties, do_paginate
      when "watched"
      @ideas = Idea.list_watched_ideas params[:page], current_user,
      filter_properties, do_paginate
      when "unread"
      @ideas = Idea.list_unread_ideas params[:page], current_user,
      filter_properties, do_paginate
      when "most_votes"
      @ideas = Idea.list_most_votes params[:page], current_user,
      filter_properties, do_paginate
      when "most_views"
      @ideas = Idea.list_most_views params[:page], current_user,
      filter_properties, do_paginate
      when "tags"
      @ideas = Idea.list_by_tags params[:page], current_user,
      filter_properties, do_paginate
    else
      @ideas = Idea.list params[:page], current_user,
      filter_properties, do_paginate
    end
  end
  
  def stream_csv
    filename = "ideas.csv" 
    
    #this is required if you want this to work with IE        
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'private'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end
    
    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n") 
      yield csv
    }
  end  
  
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
      user_idea_read = UserIdeaRead.new(:user_id => current_user.id, :last_read => Time.zone.now)
      idea.user_idea_reads << user_idea_read
    elsif
      user_idea_read.update_attributes(:last_read => Time.zone.now)
    end
  end
  
  @@change_loggers = nil
  
  def generate_change_log before_idea, after_idea
    @@change_loggers ||= [ 
    IdeaTitleChangeLog.new, 
    IdeaDescriptionChangeLog.new,
    IdeaProductChangeLog.new,
    IdeaTagsChangeLog.new,
    IdeaReleaseChangeLog.new,
    ]
    for change_logger in @@change_loggers 
      change_log = change_logger.calc_change_log(before_idea, after_idea, current_user)
      after_idea.change_logs << change_log unless change_log.nil?
    end
    RunOncePeriodicJob.create(
                              :job => "Idea.send_change_notifications(#{after_idea.id})")
  end
  
  class IdeaTitleChangeLog
    def calc_change_log before_idea, after_idea, current_user
      if before_idea.title != after_idea.title
        return IdeaChangeLog.new(
                                 :message => "Title was changed from '#{before_idea.title}' to '#{after_idea.title}'", 
        :user => current_user)
      end
    end
  end
  
  class IdeaDescriptionChangeLog
    def calc_change_log before_idea, after_idea, current_user
      if before_idea.description != after_idea.description
        return IdeaChangeLog.new(
                                 :message =>  "Description was updated", 
        :user => current_user)
      end
    end
  end
  
  class IdeaTagsChangeLog
    def calc_change_log before_idea, after_idea, current_user
      if before_idea.nondb_tag_list != after_idea.tag_list
        return IdeaChangeLog.new(
                                 :message => "Tags were updated to: #{after_idea.tag_list}", 
        :user => current_user)
      end
    end
  end
  
  class IdeaProductChangeLog
    def calc_change_log before_idea, after_idea, current_user
      if before_idea.product.id != after_idea.product.id
        return IdeaChangeLog.new(
                                 :message => "Product was updated from '#{before_idea.product.name}' to '#{after_idea.product.name}'", 
        :user => current_user)
      end
    end
  end
  
  class IdeaReleaseChangeLog
    def calc_change_log before_idea, after_idea, current_user
      if before_idea.release.nil? and !after_idea.release.nil?
        return IdeaChangeLog.new(
                                 :message => "Idea was scheduled for release #{after_idea.release.version}", 
        :user => current_user)
      elsif !before_idea.release.nil? and after_idea.release.nil?
        return IdeaChangeLog.new(
                                 :message => "Idea was previously scheduled for release #{before_idea.release.version} and is now unscheduled", 
        :user => current_user)
      elsif !before_idea.release.nil? and !after_idea.release.nil? and
        before_idea.release.id != after_idea.release.id
        return IdeaChangeLog.new(
                                 :message =>  "Idea was previously scheduled for release #{before_idea.release.version} and is now scheduled for release #{after_idea.release.version}", 
        :user => current_user)
      end
    end
  end
end
