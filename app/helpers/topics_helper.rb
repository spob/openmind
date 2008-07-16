module TopicsHelper
  def can_edit? topic
    sysadmin? or topic.forum.can_edit? current_user
  end  
end
  
def can_edit_comment? comment
  comment.can_edit?(current_user, prodmgr? || sysadmin?)
end


def show_watch_button topic
  show = ""
  if topic.watchers.include? current_user
    show = link_to "Remove Watch", 
                destroy_topic_watch_watch_path(:id => topic), 
                {:class=> "button",
                  :onmouseover => "Tip('Stop watching this topic')",
                  :method => :delete                }
  else
    show = link_to "Add Watch", 
                create_topic_watch_watch_path(topic), 
                {:class=> "button",
                  :onmouseover => "Tip('Watch this topic')",
                  :method => :post                   }
  end
  show
end