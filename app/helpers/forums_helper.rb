module ForumsHelper
  def can_edit? forum
    sysadmin? or current_user.mediated_forums.include? forum
  end  
end
