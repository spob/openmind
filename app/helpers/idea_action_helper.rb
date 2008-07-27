# 
# the votes and watches controller needs to be able to redraw idea action buttons
# as part of their ajax-based actions...therefore, place shared helper methods
# in a common location
# 

module IdeaActionHelper

  def vote_area(idea, &block)
    if show_vote? idea
      yield
    end
  end
  
  def rescind_vote_area(idea, &block)
    yield if show_rescind_vote? idea
  end

  def show_delete? idea
    can_delete_idea? idea
  end
  
  def show_edit? idea
    can_edit_idea? idea
  end
  
  def show_rescind_vote? idea
    return false unless idea.release.nil? and idea.merged_to_idea.nil?
    voter? and idea.rescindable_votes? current_user.id
  end

  def show_watch_button idea, from
    show = ""
    if idea.watched? current_user
      show = link_to_remote theme_image_tag("icons/24x24/watchRemove.png", 
        :alt=>"Remove watch", :title=> "remove watch",
        :onmouseover => "Tip('Stop watching this idea')"), 
        :url =>  watch_path(:id => @idea, :from => from), 
        :html => { :class=> "button" }, 
        :method => :delete
    else
      url = watches_path(:id => @idea)
      url = create_from_show_watches_path(:id => @idea) if from == "show"
      show = link_to_remote theme_image_tag("icons/24x24/watchAdd.png", 
        :alt=>"Add watch", :title=> "add watch",
        :onmouseover => "Tip('Watch this idea')"), 
        :url =>  url, 
        :html => { :class=> "button" }, 
        :method => :post
    end
    show
  end
  
  
  def show_merge idea
    show = ""
    restrict_to 'prodmgr' do 
      if idea.merged_to_idea.nil?
        show = link_to theme_image_tag("icons/24x24/ideasMerge.png", 
          :alt=>"Merge", :title=> "Merge"), 
          merge_idea_path(idea), 
          html_options = {:onmouseover => "Tip('Merge this idea with another one')"} 
      else
        show = link_to theme_image_tag("icons/24x24/ideasUnmerge.png", 
          :alt=>"Merge", :title=> "Merge"), 
          merge_idea_path(idea), 
          html_options = {:class=> "button", :method => :delete,
          :onmouseover => "Tip('Un-merge this idea from another')"} 
      end
    end
    show
  end
  
  private 
  
  def show_vote? idea
    return false unless idea.release.nil? and idea.merged_to_idea.nil?
    return false unless current_user.available_votes > 0
    voter? and current_user.available_votes > 0
  end
end
