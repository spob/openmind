class EmailNotifier < ActionMailer::Base
  include ActionController::UrlWriter
  
  default_url_options.update :protocol => APP_CONFIG['protocol']
  default_url_options.update :host => APP_CONFIG['host']
  default_url_options.update :port => APP_CONFIG['port']
  
  def reset_notification(user)
    setup_email(user)
    @subject    += 'Password reset, please activate your account'
    @body[:help_url] = url_for :controller => 'static', :action => 'help', :anchor => "OpenId", :only_path  => false
    @body[:url]  = url_for :controller => 'account',
      :action => 'activate',
      :id => user.activation_code,
      :only_path  => false
  end
  
  def pending_topics(topics)
    setup_email(topics.first.owner)
    @subject    += "Topics assigned to #{topics.first.owner.full_name} awaiting response"
    @body[:topics] = topics
    @body[:url]  = url_for :controller => 'forums',
      :action => 'index',
      :only_path  => false    
  end

  def reminder_to_vote(idea_id)
    idea = Idea.find(idea_id)
    setup_email(idea.user)
    @subject    += "Don't forget to vote"
    @body[:idea] = idea
    @body[:url]  = url_for :controller => 'account',
      :action => 'login',
      :only_path  => false
  end
  
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:help_url] = url_for :controller => 'static', :action => 'help', :anchor => "OpenId", :only_path  => false
    @body[:url]  = url_for :controller => 'account',
      :action => 'activate',
      :id => user.activation_code,
      :only_path  => false
    @body[:short_url]  = url_for :controller => 'account',
      :action => 'activate',
      :only_path  => false
  end
  
  def activation(user_id)
    user = User.find user_id
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = url_for :controller => 'account',
      :action => 'login',
      :only_path  => false
  end
  
  def idea_email_request(request_id)
    request = IdeaEmailRequest.find request_id
    setup_email
    @body[:email_request]  = request
    @body[:url]  = url_for :controller => 'ideas', 
      :action => 'show', 
      :id => request.idea.id,
      :only_path  => false
    @subject    += request.subject
    @cc = request.user.email if request.cc_self
    @recipients = request.to_email
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
    @bcc = idea_watcher_email_addresses comment.idea
  end
  
  def new_user_request_notification(user_request_id)
    setup_email
    request = UserRequest.find(user_request_id)
    @body[:email] = request.email
    @body[:first_name] = request.first_name
    @body[:last_name] = request.last_name
    @body[:enterprise] = request.enterprise_name
    @subject    += "User #{request.email} has requested an OpenMind account"
    @recipients = User.sysadmins.collect(&:email)
  end
  
  def user_request_received_notification(user_request_id)
    setup_email
    request = UserRequest.find(user_request_id)
    @body[:email] = request.email
    @body[:admin_email] = APP_CONFIG['admin_email']
    @body[:first_name] = request.first_name
    @body[:last_name] = request.last_name
    @body[:enterprise] = request.enterprise_name
    @subject    += "Your account request has been received"
    @recipients = request.email
  end
  
  def new_user_allocation_notification(allocation_id)
    allocation = UserAllocation.find(allocation_id)
    setup_allocation_email allocation
    @subject   += "You just received a new allocation for #{StringUtils.pluralize(allocation.quantity, 'unit')}"
    @recipients = allocation.user.email
    set_expiration_date allocation
  end
  
  def new_enterprise_allocation_notification allocation_id
    allocation = EnterpriseAllocation.find(allocation_id)
    setup_allocation_email allocation
    @subject   += "#{allocation.enterprise.name} just received a new allocation for #{StringUtils.pluralize(allocation.quantity, 'unit')}"
    @recipients = ''
    @bcc = allocation.enterprise.users.active.collect(&:email)
    set_expiration_date allocation
  end
  
  def idea_change_notifications(idea)
    return if idea.watchers.empty?
    
    setup_email
    @body[:url]  = url_for :controller => 'ideas',
      :action => 'show', 
      :id => idea.id,
      :only_path  => false
    @body[:change_notices] = idea.unprocessed_change_logs.collect(&:message)
    @body[:idea] = idea
    @subject    += "Idea ##{idea.id} was updated"
    @recipients = ''
    @bcc = idea_watcher_email_addresses idea
  end

  def release_change_notifications(release)
    return if release.product.watchers.empty?

    setup_email
    @body[:url]  = url_for :controller => 'releases', :action => 'show',
      :id => release.id, :only_path  => false
    @body[:change_notices] = release.unprocessed_change_logs.collect(&:message)
    @body[:release] = release
    @subject    += "Release #{release.version} for product #{release.product.name} was updated"
    @recipients = ''
    @bcc = release_watcher_email_addresses release
  end
  
  def new_topic_comment_notification(topics, user)
    setup_email
    @body[:topics]  = topics
    @body[:user] = user
    @subject    += "New Topic Comments"
    @recipients = user.email
  end
  
  protected
  def setup_email(user=nil)
    @recipients  = "#{user.email}" unless user.nil?
    @from        = APP_CONFIG['admin_email']
    @subject     = APP_CONFIG['email_subject_prefix']
    @subject        += ': ' unless @subject =~ /:\s$/
    @subject        += ' ' if @subject =~ /:$/
    @sent_on     = Time.zone.now
    @body[:user] = user unless user.nil?
    @body[:email_image_url] = APP_CONFIG['email_image_url']
    @body[:date_stamp] = Time.zone.now.strftime "%A, %B %d, %Y"
  end
  
  def idea_watcher_email_addresses idea
    idea.watchers.find_all_by_active(true).collect(&:email)
  end

  def release_watcher_email_addresses release
    release.product.watchers.find_all_by_active(true).collect(&:email)
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
end
