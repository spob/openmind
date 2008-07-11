module ForumsHelper
  def can_edit? forum
    sysadmin? or forum.can_edit? current_user
  end
  
  def last_posting_date topic
    return '-' if topic.last_comment.nil?
    om_date_time(topic.last_comment.created_at)
  end
  
  def last_post forum
    last_comment = forum.comments.first #this isn't very efficient...replace by sql?
    return '-' if last_comment.nil?
    "<b>#{last_comment.topic.title}</b><br/>by <b>#{user_display_name last_comment.user}</b><br/>#{om_date_time last_comment.created_at}"
  end
end
