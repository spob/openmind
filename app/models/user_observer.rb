class UserObserver < ActiveRecord::Observer
  def after_create(user)
    EmailNotifier.deliver_signup_notification(user) unless user.activation_code.blank?
  end

  def after_save(user)
    RunOncePeriodicJob.create(
      :job => "EmailNotifier.deliver_activation(#{user.id})") if user.recently_activated?
    #    EmailNotifier.deliver_activation(user) if user.recently_activated?
  end
end