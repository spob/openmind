# Settings specified here will take precedence over those in config/environment.rb

# uncomment the following if you wish to use gmail
#require 'tlsmail'
#Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.cache_store = :file_store, File.dirname(__FILE__) + '/../../tmp/cache'

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = true

ActionMailer::Base.default_content_type = "text/html"

  ActionMailer::Base.smtp_settings = {
    :address => '192.168.254.13',
    :port => 25
#    :tls => true,
#    :authentication => :plain,
#    :user_name => 'admin@openmind.scribesoftware.com',
#    :password => '3ma1l0p3nm1nd'
  }
