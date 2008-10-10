module TopicsHelper
  def can_edit_topic? topic
    sysadmin? or topic.forum.can_edit? current_user
  end  
  
  def can_edit_comment? comment
    comment.can_edit?(current_user, prodmgr? || sysadmin?)
  end


  def show_topic_watch_button topic
    if topic.watchers.include? current_user
      link_to "Remove Watch", 
        destroy_topic_watch_watch_path(:id => topic), 
        { :class => "button",
        :onmouseover => "Tip('Stop watching this topic')",
        :method => :delete                }
    else
      link_to "Add Watch", 
        create_topic_watch_watch_path(topic), 
        { :class => "button",
        :onmouseover => "Tip('Watch this topic')",
        :method => :post                   }
    end
  end

  def expand_contract_box_image
    image = "show.png"
    help = "Show topic details"
    if session[:topic_details_box_display] == "SHOW"
      image = "hide.png" 
      help = "Hide topic details"
    end
    theme_image_tag("icons/16x16/#{image}", :alt=> help, :title=> help,
      :onmouseover => "Tip('#{help}')")
  end
  
  def topic_details_box_display_style
    return "display:block;" if session[:topic_details_box_display] == "SHOW"
    return "display:none;"
  end
end