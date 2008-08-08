require 'exceptions/vote_exception'

class VotesController < ApplicationController
  helper :idea_action, :ideas
  before_filter :login_required
  access_control [:create, :destroy] => 'voter'

  def index
    @selected_user = nil
    @selected_user = User.find(params[:user_id]) unless params[:user_id].nil?
    
    @selected_enterprise = nil
    @selected_enterprise = Enterprise.find(params[:enterprise_id]) unless params[:enterprise_id].nil?
    @votes = Vote.list params[:page], current_user.row_limit, 
      params[:enterprise_id], params[:user_id]
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create, :create_from_show ],
    :redirect_to => { :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :action => :index }

  # collection routes apparently can't take additonal parameters other than id...
  # so, a bit of a kludge, if we can't pass a from parameter to indicate whether
  # the action was originated from the list page or the show page, I added another
  # action to indicate the difference
  def create_from_show
    create "show"  
  end
  
  def create from="list"
    @idea = Idea.find(params[:id])
    begin
      watch_string = ""
      if current_user.watch_on_vote and !@idea.watched? current_user
      	@idea.watchers << current_user
      	watch_string = " and idea is being watched"
  	  end
  	  
      @idea.vote current_user
      session[:selected_tab] = "VOTES" if from == "show"
      flash[:notice] = "Vote recorded for idea number #{@idea.id}#{watch_string}"
    rescue VoteException
      flash[:notice] = "You don't have enough votes available to vote"
    end
    
    do_response from
  end

  def destroy
    @idea = Idea.find(params[:id])
    begin
      @idea.rescind_vote current_user
      session[:selected_tab] = "VOTES" if params[:from] == "show"
      session[:selected_tab] = "DETAILS" if @idea.votes.empty?
      flash[:notice] = "Vote rescinded for idea number #{@idea.id}"
    rescue VoteException
      flash[:notice] = "No vote to rescind"
    end
    
    do_response params[:from]
  end
  
  private
  
  def do_response from
    respond_to do |format|
      format.html { redirect_to :controller => 'ideas', :action => 'show', :id  => @idea }
      format.js  { do_rjs from }
    end
  end
  
  def do_rjs from
    render :update do |page|
      if from == "show"
        partial = "votes/votes"
        partial = "ideas/idea_details" if session[:selected_tab] == "DETAILS"
        page.replace "tabBody",  :partial => partial, :object => @idea
        page.replace "tabs",  :partial => "ideas/tabs", :object => @idea
      end
      page.replace_html :user_count, current_user.available_user_votes
      page.visual_effect :blind_down, "user_count", :duration => 2
      page.replace_html :enterprise_count, current_user.available_enterprise_votes
      page.visual_effect :blind_down, "enterprise_count", :duration => 2
      page.replace_html :total_count, current_user.available_votes
      page.visual_effect :blind_down, "total_count", :duration => 2
      page.replace_html "vote_count#{@idea.id.to_s}", @idea.votes.size
      page.visual_effect :blind_down, "vote_count#{@idea.id.to_s}", :duration => 2
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
end
