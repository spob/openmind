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
    idea.change_logs << IdeaChangeLog.new(
      :message => "Idea was merged into idea ##{merged_to_idea.id}", 
      :user => current_user)
    idea.save
    RunOncePeriodicJob.create(
      :job => "Idea.send_change_notifications(#{idea.id})")
    
    idea.merged_to_idea.change_logs << IdeaChangeLog.new(
      :message => "Idea ##{idea.id} was merged into this idea", 
      :user => current_user)
    idea.merged_to_idea.save
    RunOncePeriodicJob.create(
      :job => "Idea.send_change_notifications(#{idea.merged_to_idea.id})")
      
    flash[:notice] = "Idea number #{idea.id} was successfully merged with idea number #{idea.merged_to_idea.id}."
    redirect_to :controller => 'ideas', :action => 'show', :id => idea
  end
  
  def destroy
    idea = Idea.find(params[:id])
    if idea.merged_to_idea.nil?
      raise Exception("Cannot unmerge an unmerged idea")
    else
      Idea.transaction do
        merged_to_idea = idea.merged_to_idea
        idea.update_attribute(:merged_to_idea, nil)
      
        idea.change_logs << IdeaChangeLog.new(
          :message => "Idea was previously merged with idea ##{merged_to_idea.id} but is no longer merged", 
          :user => current_user)
        RunOncePeriodicJob.create(
          :job => "Idea.send_change_notifications(#{idea.id})")
        
      
        merged_to_idea.change_logs << IdeaChangeLog.new(
          :message => "Idea ##{idea.id} was previously merged with this idea but is no longer merged", 
          :user => current_user)
        merged_to_idea.save
        RunOncePeriodicJob.create(
          :job => "Idea.send_change_notifications(#{merged_to_idea.id})")
      end
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
