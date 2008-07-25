class EmailNotifier < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options.update :host => APP_CONFIG['host']
  default_url_options.update :port => APP_CONFIG['port']
  
  def reset_notification(user)
    setup_email(user)
    @subject    += 'Password reset, please activate your new account'
    @body[:url]  = url_for :controller => 'account',
      :action => 'activate',
      :id => user.activation_code,
      :only_path  => false
  end
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = url_for :controller => 'account',
      :action => 'activate',
      :id => user.activation_code,
      :only_path  => false
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = url_for :controller => 'account',
      :action => 'login',
      :only_path  => false
  end
  
  def new_comment_notification(comment_id)
    comment = Comment.find(comment_id)
    setup_email
    @body[:url]  = url_for :controller => 'ideas',
      :action => 'show', 
      :id => comment.idea.id,
      :only_path  => false
    @body[:comment] = comment
    @subject    += "Idea ##{comment.idea.id} has a new comment"
    @recipients = ''
    @bcc = watcher_email_addresses comment.idea
  end
  
  def new_user_allocation_notification(allocation)
    setup_allocation_email allocation
    @subject   += "You just received a new allocation for #{StringUtils.pluralize(allocation.quantity, 'unit')}"
    @recipients = allocation.user.email
    set_expiration_date allocation
  end
  
  def new_enterprise_allocation_notification allocation
    setup_allocation_email allocation
    @subject   += "#{allocation.enterprise.name} just received a new allocation for #{StringUtils.pluralize(allocation.quantity, 'unit')}"
    @recipients = ''
    @bcc = allocation.enterprise.active_users.collect(&:email)
    set_expiration_date allocation
  end
  
  def idea_change_notifications(idea, change_notices)
    setup_email
    @body[:url]  = url_for :controller => 'ideas',
      :action => 'show', 
      :id => idea.id,
      :only_path  => false
    @body[:change_notices] = change_notices
    @body[:idea] = idea
    @subject    += "Idea ##{idea.id} was updated"
    @recipients = ''
    @bcc = watcher_email_addresses idea
  end
  
  protected
  def setup_email(user=nil)
    @recipients  = "#{user.email}" unless user.nil?
    @from        = APP_CONFIG['admin_email']
    @subject     = APP_CONFIG['email_subject_prefix']
    @subject        += ': ' unless @subject =~ /:\s$/
    @subject        += ' ' if @subject =~ /:$/
    @sent_on     = Time.now
    @body[:user] = user unless user.nil?
    @body[:email_image_url] = APP_CONFIG['email_image_url']
    @body[:date_stamp] = Time.now.strftime "%A, %B %d, %Y"
  end
  
  def watcher_email_addresses idea
    idea.watchers.find_all_by_active(true).collect(&:email)
  end
  
  def setup_allocation_email allocation
    setup_email
    @body[:url]  = url_for :controller => 'ideas',
      :action => 'list',
      :only_path  => false
    @body[:allocation] = allocation
  end
  
  def set_expiration_date allocation
    @body[:expiration_date] = allocation.expiration_date.strftime("%b %d, %Y")
  end
  
  def new_topic_comment_notification(topics, user)
    setup_email
    @body[:topics]  = topics
    @body[:user] = user
    @subject    += "New Topic Comments"
    @recipients = user.email
  end
end