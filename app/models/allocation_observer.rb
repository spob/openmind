class AllocationObserver < ActiveRecord::Observer
  def after_create(allocation)
    if allocation.class == UserAllocation
      RunOncePeriodicJob.create(
      	:job => "EmailNotifier.deliver_new_user_allocation_notification(#{allocation.id})") if allocation.user.active && !allocation.user.activated_at.nil?
      # EmailNotifier.deliver_new_user_allocation_notification(allocation) if allocation.user.active && !allocation.user.activated_at.nil?
    else
      RunOncePeriodicJob.create(
      	:job => "EmailNotifier.deliver_new_enterprise_allocation_notification(#{allocation.id})") unless allocation.enterprise.users.active.empty?
      # EmailNotifier.deliver_new_enterprise_allocation_notification(allocation) unless allocation.enterprise.users.active.empty?
    end
  end
end