module ForumsHelper
  def can_edit? forum
    sysadmin? or forum.can_edit? current_user
  end  
end
