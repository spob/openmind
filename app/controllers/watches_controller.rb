class WatchesController < ApplicationController
  helper :idea_action
  before_filter :login_required
  
  verify :method => :post, :only => [:create, :create_from_show ],
    :redirect_to =>{ :controller => 'ideas', :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :controller => 'ideas', :action => :list }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :controller => 'ideas', :action => :list }
  
  # collection routes apparently can't take additonal parameters other than id...
  # so, a bit of a kludge, if we can't pass a from parameter to indicate whether
  # the action was originated from the list page or the show page, I added another
  # action to indicate the difference
  def create_from_show
    create "show"  
  end
  
  def create from="list"
    begin
      @idea = Idea.find(params[:id])
      @idea.watchers << current_user
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to add watch to invalid idea #{params[:id]}")
      flash[:notice] = "Attempted to add watch to invalid idea"
      #list
      
      respond_to do |format|
        format.html {render :controller => 'ideas', :action => 'list' }
        format.js  { do_action from  }
      end
      return false
    else
      flash[:notice] = "Idea number #{@idea.id} is being watched."
    
      respond_to do |format|
        format.html {redirect_to :controller => 'ideas', :action => 'show', :id  => @idea }
        format.js  { do_action  from }      
      end 
    end
  end

  def destroy
    begin
      @idea = Idea.find(params[:id])
      @idea.watchers.delete(current_user)
    rescue ActiveRecord::RecordNotFound     
      logger.error("Attempt to remove watch from invalid idea #{params[:id]}")
      flash[:notice] = "Attempted to remove watch from invalid idea"
      #list      
      respond_to do |format|
        format.html {render :controller => 'ideas', :action => 'list' }
        format.js  { do_action   }
      end
      return false
    else
      flash[:notice] = %(Watch removed from Idea number #{@idea.id}.)
      
      respond_to do |format|
        format.html {redirect_to :controller => 'ideas', :action => 'show', :id  => @idea }
        format.js  { do_action params[:from]  }
      end      
    end  
  end
    
  private
    
  def do_action from="list"
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
end
