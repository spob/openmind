# To change this template, choose Tools | Templates
# and open the template in the editor.

class ForumsSweeper < ActionController::Caching::Sweeper
  observe Forum # This sweeper is going to keep an eye on the Forum model

  # If our sweeper detects that a forum was created call this
  def after_save(forum)
    expire_cache_for(forum)
  end

  # If our sweeper detects that a forum was deleted call this
  def after_destroy(forum)
    expire_cache_for(forum)
  end

  def after_forums_mark_all_as_read
    expire_fragment(%r{forums/list_forums.user_id=#{current_user.id}})
  end

  def after_watches_create_forum_watch
    kill_list_forums_cache
  end

  def after_watches_destroy_forum_watch
    kill_list_forums_cache
  end

  private
  def expire_cache_for(record)
    # Expire a fragment
    kill_list_forums_cache
    expire_fragment(%r{forums/most_active.forum=-1&user_id=*})
    #    expire_fragment(:controller => 'forums', :action => 'index',
    #      :page => params[:page] || 1)
  end

  def kill_list_forums_cache
    expire_fragment(%r{forums/list_forums.user_id=*})
  end
end