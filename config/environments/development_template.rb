# When developing against openmind, rename or copy this file to a filed named 
# development.rb. Make changes specific to your environment (such as mail servers)
# to your copied file, not to this file.

require 'tlsmail'
Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)

# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

ActionMailer::Base.default_content_type = "text/html"

#ActionMailer::Base.smtp_settings = {
  #  :address  => "localhost",
  #  :port  => 25, 
  #  :domain  => "www.openmind.org",
  #  :user_name  => 'user',
  #  :password  => "changeme",
  #  :authentication  => :login
#}
  config.action_mailer.raise_delivery_errors = true
  
require 'ruby-debug'