# To change this template, choose Tools | Templates
# and open the template in the editor.

class AllocationsSweeper < ActionController::Caching::Sweeper
  observe Allocation # This sweeper is going to keep an eye on the allocation model

  # If our sweeper detects that an allocation was created call this
  def after_save(allocation)
    expire_cache_for(allocation)
  end

  # If our sweeper detects that an allocation was deleted call this
  def after_destroy(allocation)
    expire_cache_for(allocation)
  end

  def after_votes_create
    expire_cache current_user
  end

  def after_votes_destroy
    expire_cache current_user
  end

  def after_account_login
    expire_cache current_user
  end

  def after_account_continue_openid
    expire_cache current_user
  end

  private
  def expire_cache_for(allocation)
    if allocation.class.to_s == 'UserAllocation'
      expire_cache(allocation.user)
    else
      for user in allocation.enterprise.users
        expire_cache(user)
      end
    end
  end

  def expire_cache(user)
    # Expire a fragment
    expire_fragment(:controller => "allocations", :action => "my_allocations",
      :user_id => (user == :false ? -1 : user.id))
  end
end