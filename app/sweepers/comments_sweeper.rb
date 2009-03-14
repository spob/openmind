# To change this template, choose Tools | Templates
# and open the template in the editor.

class CommentsSweeper < ActionController::Caching::Sweeper
  observe Comment # This sweeper is going to keep an eye on the comment model

  # If our sweeper detects that a comment was created call this
  def after_save(comment)
    expire_cache_for(comment)
  end

  # If our sweeper detects that a comment was deleted call this
  def after_destroy(comment)
    expire_cache_for(comment)
  end

  private
  def expire_cache_for(comment)
    # Expire a fragment
    if comment.class.to_s == 'TopicComment'
      expire_fragment(%r{forums/list_forums.user_id=*})
      expire_fragment(%r{forums/most_active.forum=-1&user_id=*})
      expire_fragment(%r{forums/most_active.forum=#{comment.topic.forum.id}&user_id=*})
      #    expire_fragment(:controller => 'comments', :action => 'index',
      #      :page => params[:page] || 1)
    end
  end
end