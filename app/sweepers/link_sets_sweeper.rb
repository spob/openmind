# To change this template, choose Tools | Templates
# and open the template in the editor.

class LinkSetsSweeper < ActionController::Caching::Sweeper
  observe LinkSet # This sweeper is going to keep an eye on the link_set model

  # If our sweeper detects that an link_set was created call this
  def after_save(link_set)
    expire_cache_for(link_set)
  end

  # If our sweeper detects that an link_set was deleted call this
  def after_destroy(link_set)
    expire_cache_for(link_set)
  end

  private
  def expire_cache_for(link_set)
    # Expire a fragment
    expire_fragment(:controller => 'link_sets', :action => 'show_links',
      :link_set_id => link_set.id)
  end
end