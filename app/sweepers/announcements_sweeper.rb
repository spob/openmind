# To change this template, choose Tools | Templates
# and open the template in the editor.

class AnnouncementsSweeper < ActionController::Caching::Sweeper
  observe Announcement # This sweeper is going to keep an eye on the announcement model

  # If our sweeper detects that an announcement was created call this
  def after_save(announcement)
    expire_cache_for(announcement)
  end

  # If our sweeper detects that an announcement was deleted call this
  def after_destroy(announcement)
    expire_cache_for(announcement)
  end

  def after_announcements_index
    expire_fragment(:controller => 'announcements', :action => 'top_five',
      :user_id => (logged_in? ? current_user.id : -1))
  end

  private
  def expire_cache_for(record)
    # Expire a fragment
    expire_fragment(%r{announcements/top_five.user_id=*})
  end
end