class MergeIdeasController < ApplicationController
  before_filter :login_required
  access_control [:merge, :unmerge, :show_merge] => 'prodmgr'
 
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create ],
    :redirect_to =>{ :controller => 'ideas', :action => :index }
  verify :method => :put, :only => [ :update ],
    :redirect_to => { :controller => 'ideas', :action => :index }
  verify :method => :delete, :only => [ :destroy ],
    :redirect_to => { :controller => 'ideas', :action => :index }
  
  def create
    idea = Idea.find(params[:id])
    merged_to_idea = Idea.find(params[:merged_into_idea_id])
    idea.merge_into(merged_to_idea)
    idea.save
    idea.merged_to_idea.save
      
    EmailNotifier.deliver_idea_change_notifications(idea, 
      Array("Idea was merged into idea ##{merged_to_idea.id}")) if !idea.watchers.empty?
      
    flash[:notice] = "Idea number #{idea.id} was successfully merged with idea number #{idea.merged_to_idea.id}."
    redirect_to :controller => 'ideas', :action => 'show', :id => idea
  end
  
  def destroy
    idea = Idea.find(params[:id])
    if idea.merged_to_idea.nil?
      raise Exception("Cannot unmerge an unmerged idea")
    else
      merged_to_id = idea.merged_to_idea.id
      idea.update_attribute(:merged_to_idea, nil)
      
    EmailNotifier.deliver_idea_change_notifications(idea, 
      Array("Idea was previously merged with idea ##{merged_to_id} but is no longer merged")) if !idea.watchers.empty?
    
      flash[:notice] = "Idea number #{idea.id} was successfully unmerged."
    end
    redirect_to :controller => 'ideas', :action => 'show', :id => idea
  end
  
  def show
    sql = 
      <<-END
        (ideas.title like ? or ideas.id like ?) and
        ideas.id <> ? and 
        ideas.merged_to_idea_id is null and
        ideas.product_id = ?
    END
    search_string = "%#{params[:id_title_filter]}%"
    @idea = Idea.find params[:id]
    @ideas = Idea.list params[:page], current_user,
      {}, true, sql,
      [search_string, search_string, @idea.id, @idea.product.id ]
  end
end
