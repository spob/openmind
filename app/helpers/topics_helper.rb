module TopicsHelper
  def can_edit? topic
    sysadmin? or topic.forum.can_edit? current_user
  end  
end
  
  def can_edit_comment? comment
    comment.can_edit?(current_user, prodmgr? || sysadmin?)
  end
