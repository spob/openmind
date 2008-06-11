class AllocationObserver < ActiveRecord::Observer
  def after_create(allocation)
    if allocation.class == UserAllocation
      EmailNotifier.deliver_new_user_allocation_notification(allocation) if allocation.user.active && !allocation.user.activated_at.nil?
    else
      EmailNotifier.deliver_new_enterprise_allocation_notification(allocation) unless allocation.enterprise.active_users.empty?
    end
  end
end