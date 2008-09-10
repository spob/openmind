class UserRequestObserver < ActiveRecord::Observer
  def after_create(user_request)
    RunOncePeriodicJob.create(
      :job => "EmailNotifier.deliver_new_user_request_notification(#{user_request.id})")
  end
end