class UserObserver < ActiveRecord::Observer
  def after_create(user)
    EmailNotifier.deliver_signup_notification(user) unless user.activation_code.blank?
  end

  def after_save(user)
    EmailNotifier.deliver_activation(user) if user.recently_activated?
  end
end