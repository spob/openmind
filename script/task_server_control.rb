# script/task_server_control.rb
#!/usr/bin/env ruby
#
# Background Task Server Control - A daemon for running jobs
#

require 'rubygems'
require 'daemons'

options = {}

default_pid_dir = File.dirname(__FILE__) + '/../tmp/pids'

if File.exists?(default_pid_dir)
  options[:dir_mode] = :normal
  options[:dir] = default_pid_dir
end

Daemons.run(File.dirname(__FILE__) + '/../script/task_server.rb', options)