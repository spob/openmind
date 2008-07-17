module ForumsHelper
  def can_edit? forum
    sysadmin? or forum.can_edit? current_user
  end
  
    
  def last_post forum
    last_comment = forum.comments.first #this isn't very efficient...replace by sql?
    return '-' if last_comment.nil?
    "<b>#{last_comment.topic.title}</b><br/>by <b>#{user_display_name last_comment.user}</b><br/>#{om_date_time last_comment.created_at}"
  end
  

  def show_topic_watch_button topic
    show = ""
    if topic.watchers.include? current_user
      show = link_to_remote theme_image_tag("icons/24x24/watchRemove.png", 
        :alt=>"Remove watch", :title=> "remove watch",
        :onmouseover => "Tip('Stop watching this topic')"), 
        :url =>  destroy_topic_watch_watch_path(:id => topic), 
        :html => { :class=> "button" }, 
        :method => :delete
    else
      show = link_to_remote theme_image_tag("icons/24x24/watchAdd.png", 
        :alt=>"Add watch", :title=> "add watch",
        :onmouseover => "Tip('Watch this topic')"), 
        :url =>  create_topic_watch_watch_path(:id => topic),
        :html => { :class=> "button" }, 
        :method => :post
    end
    show
  end
end