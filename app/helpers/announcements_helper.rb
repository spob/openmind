module AnnouncementsHelper

  def admin_area(&block)
    if allow_edit?
      yield
    end
  end
  
  private
  
  def allow_edit?
    prodmgr? or sysadmin?
  end
end
