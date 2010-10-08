# Settings specified here will take precedence over those in config/environment.rb

# uncomment the following if you wish to use gmail
#require 'tlsmail'
#Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new
config.logger = Logger.new(config.log_path, 14, 5.megabyte)
config.logger.level = Logger::INFO

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
      :address => '192.168.254.18',
      :port => 25
#      :authentication => :plain,
#      :user_name => 'smtp.relay@scribesoft.com',
#      :password => 'ScribeHq3',
#      :domain => 'scribesoft.com'
# 2/1/2010     :address => 'mail.authsmtp.com',
#     :port => 23,
#     :authentication => :login,
#     :user_name => 'ac47427',
#     :password => 'zkre2rdtj',
#     :domain => 'scribesoft.com'
# 4/19/2010    :address => '192.168.254.45',
#     :port => 25
# 11/16/09    :address => '192.168.12.50',
#    :tls => true,
#    :authentication => :plain,
#    :user_name => 'admin@openmind.scribesoftware.com',
#    :password => '3ma1l0p3nm1nd'
  }
