module TopicsHelper
  def can_edit_topic? topic
    sysadmin? or topic.forum.can_edit? current_user
  end  
end
  
def can_edit_comment? comment
  comment.can_edit?(current_user, prodmgr? || sysadmin?)
end


def show_topic_watch_button topic
  if topic.watchers.include? current_user
    link_to "Remove Watch", 
                destroy_topic_watch_watch_path(:id => topic), 
                {:class=> "button",
                  :onmouseover => "Tip('Stop watching this topic')",
                  :method => :delete                }
  else
    link_to "Add Watch", 
                create_topic_watch_watch_path(topic), 
                {:class=> "button",
                  :onmouseover => "Tip('Watch this topic')",
                  :method => :post                   }
  end
end