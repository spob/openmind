set :application, "set your application name here"
set :repository,  "set your repository location here"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "your app-server here"
role :web, "your web-server here"
role :db,  "your db-server here", :primary => true

set :application, "openmind"            # Can be whatever you want, I use the project name from my SVN repository
set :domain, "www.openmind.com"        # The URL for your app
set :user, "username"                  # Your HostingRails username
set :repository,  "svn+ssh://#{user}@#{domain}/home/#{user}/svn/#{application}/trunk"  # The repository location for svn+ssh access# 
# set :repository, "http://svn.#{domain}/svn/#{application}/trunk"      # The repository location for http accessset :use_sudo, false                	# HostingRails users don't have sudo access
set :deploy_to, "/home/#{user}/apps/#{application}"          # Where on the server your app will be deployed
set :deploy_via, :checkout                # For this tutorial, svn checkout will be the deployment method
set :chmod755, "app config db lib public vendor script script/* public/disp*"  	# Some files that will need proper permissions# 
# set :mongrel_port, "4444"                # Mongrel port# 
# set :mongrel_nodes, "4"                # Number of Mongrel instances for those with multiple Mongrels
default_run_options[:pty] = true
# Cap won't work on windows without the above line, see
# http://groups.google.com/group/capistrano/browse_thread/thread/13b029f75b61c09d
# Its OK to leave it true for Linux/Mac
ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys
role :app, domain
role :web, domain
role :db,  domain, :primary => true