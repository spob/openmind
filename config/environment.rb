# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '1.2.6' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  #Add load paths to vendor gems
  config.load_paths += Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Add new inflection rules using the following format
  # (all these examples are active by default):
  # Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
  # end

  # See Rails::Configuration for more options
  config.active_record.observers = :user_observer, :comment_observer, :allocation_observer
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
# load the base application config file

# see http://lemurware.blogspot.com/2006/08/ruby-on-rails-configuration-and.html
# RBS 1/1/2008
path = "#{RAILS_ROOT}/config/environment.yml"
APP_CONFIG = YAML.load_file(path)

# load and merge in the environment-specific application config info
# if present, overriding base config parameters as specified
path = "#{RAILS_ROOT}/config/environments/#{ENV['RAILS_ENV']}.yml"
if File.exists?(path) && (env_config = YAML.load_file(path))
  APP_CONFIG.merge!(env_config)
end


# Required to support hard line breaks
# See http://wiki.rubyonrails.org/rails/pages/RedCloth for a discussion
#class RedCloth
#  # Patch for RedCloth.  Fixed in RedCloth r128 but _why hasn't released it yet.
#  # <a href="http://code.whytheluckystiff.net/redcloth/changeset/128">http://code.whytheluckystiff.net/redcloth/changeset/128</a>
#  def hard_break( text ) 
#    text.gsub!( /(.)\n(?!\n|\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br />" ) if hard_breaks 
#  end 
#end
 
if $t.nil?
  $t = Thread.new {
    while true do
      sleep(60)
      # Find all Run Once jobs, and run them
      RunOncePeriodicJob.find_all_need_to_run.each do |job|
        job.run!
      end

      # Find all Run on Interval jobs, and run them  
      RunIntervalPeriodicJob.find_all_need_to_run.each do |job|
        job.run!
      end

      # Find all Run At jobs, and run them  
      RunAtPeriodicJob.find_all_need_to_run.each do |job|
        job.run!
      end

      # Cleans up periodic jobs, removes all RunOncePeriodicJobs over one
      # day old.
      RunOncePeriodicJob.cleanup
    end
  }
end
 
#t.join # wait for thread to exit (never, in this case)