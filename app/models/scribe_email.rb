class ScribeEmail < ActionMailer::Base
  include ActionController::UrlWriter

  default_url_options.update :host => APP_CONFIG['host']
  default_url_options.update :port => APP_CONFIG['port']

  def scribe_feedback_notification(email, comments)
    setup_email
    @recipients  = "productfeedback@scribesoft.com"
    @subject    += 'You have received product feedback'
    @body[:from_email]  = email
    @body[:comments]  = comments
    @body[:url]  = url_for :controller => 'account',
      :action => 'login',
      :only_path  => false
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
end
