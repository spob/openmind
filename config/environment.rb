# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when you don't control
# web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

#  config.load_once_paths += %W{ #{RAILS_ROOT}/app/controllers/allocations_controller.rb }
  # Use spaces instead of commas for tags separator

  # required gems
  config.gem 'mislav-will_paginate', :lib => 'will_paginate',
             :source                      => 'http://gems.github.com'

  # Uncomment the following line if you are using RedCloth -- only required for implementations
  # that upgraded from a 1.x version of OpenMind
  config.gem 'RedCloth', :lib => 'redcloth', :version => '>= 3.315'

  # Require the latest version of mysql
  config.gem "mysql"

  config.gem "rmagick", :lib => "RMagick2"

  config.gem "fastercsv"

  config.gem "friendly_id"

  config.gem "hpricot"

  config.gem 'hoptoad_notifier'

  config.gem 'newrelic_rpm'

  config.gem "daemons"

  config.gem "pdfkit"

  config.gem 'thoughtbot-shoulda', :lib => 'shoulda/rails', :source => "http://gems.github.com"

  config.gem "ruby-yadis", :lib => 'yadis', :version => '0.3.4'

  config.gem "ruby-openid", :lib => 'openid', :version => '1.1.4'

  config.gem(
      'thinking-sphinx',
      :lib     => 'thinking_sphinx',
      :version => '1.3.20')

  # Default timezone...Set this to the timezone where the server resides
  config.time_zone                              = 'Eastern Time (US & Canada)'

  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add load paths to vendor gems
  config.load_paths                             += Dir["#{RAILS_ROOT}/vendor/**"].map do |dir|
    File.directory?(lib = "#{dir}/lib") ? lib : dir
  end


  # Only load the plugins named here, by default all plugins in vendor/plugins
  # are loaded config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs config.load_paths += %W(
  # #{RAILS_ROOT}/extras )
  config.load_paths                             += %W( #{RAILS_ROOT}/app/sweepers )

  # Force all environments to use the same logger level (by default production
  # uses :info, the others :debug)
  config.log_level                              = :debug

  # Use the database for sessions instead of the file system (create the session
  # table with 'rake db:sessions:create')
  config.action_controller.session_store        = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test
  # database. This is necessary if your schema can't be completely dumped by the
  # schema dumper, like if you have constraints or database-specific column
  # types config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  config.action_controller.page_cache_directory = RAILS_ROOT + "/tmp/cache"

  # Add new inflection rules using the following format (all these examples are
  # active by default): Inflector.inflections do |inflect|
  #   inflect.plural /^(ox)$/i, '\1en'
  #   inflect.singular /^(ox)en/i, '\1'
  #   inflect.irregular 'person', 'people'
  #   inflect.uncountable %w( fish sheep )
  # end

  # needed for pdfkit
#  config.middleware.use "PDFKit::Middleware", :print_media_type => true


  # set our session key to distinguish it from others
  config.action_controller.session = {:key => '_OpenMind_session_id'}

  # See Rails::Configuration for more options
  # This is a total hack...caused by the fact that by instantiating the observers,
  # rails will look at the models, which will cause acts_as_solr to look for the
  # tables, which will not have been created yet in the case of the initial migration.
  if FileTest.exist?("#{RAILS_ROOT}/config/observe.txt")
    config.active_record.observers = :user_observer,
        :comment_observer,
        :allocation_observer,
        :user_request_observer,
        :idea_observer
  else
    puts "Observers are disabled. This should be the case if you've not yet run"
    puts "your initial migration. Once the initial migration is complete, you should"
    puts "enable observers by copy the file:"
    puts "#{RAILS_ROOT}/config/observe.no.txt"
    puts "to"
    puts "#{RAILS_ROOT}/config/observe.txt"
  end

  path       = "#{RAILS_ROOT}/config/environment.yml"
  APP_CONFIG = YAML.load_file(path)

  # load and merge in the environment-specific application config info if present,
  # overriding base config parameters as specified
  path       = "#{RAILS_ROOT}/config/environments/#{ENV['RAILS_ENV']}.yml"
  if File.exists?(path) && (env_config = YAML.load_file(path))
    APP_CONFIG.merge!(env_config)
  end
end

# Add new mime types for use in respond_to blocks: Mime::Type.register
# "text/richtext", :rtf Mime::Type.register "application/x-mobile", :mobile
Mime::SET << Mime::CSV

# Include your application configuration below load the base application config
# file #require 'redcloth' require
# "#{File.expand_path(RAILS_ROOT)}/vendor/daemons-1.0.10/lib"

# see http://lemurware.blogspot.com/2006/08/ruby-on-rails-configuration-and.html
# RBS 1/1/2008

WhiteListHelper.tags.merge %w(u table tbody tr td iframe)
WhiteListHelper.attributes.merge %w(id class style src target align frameborder marginheight marginwidth)

