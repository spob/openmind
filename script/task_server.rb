# script/task_server.rb
#!/usr/bin/env ruby
#
# Background Task Server
#
# Relies on ActiveRecord PeriodicJob and STI table (periodic_jobs):
#
# type:         string    ("RunOncePeriodicJob", or "RunIntervalPeriodicJob")
# interval:     integer   (in seconds)
# job:          text      (actual ruby code to eval)
# last_run_at:  datetime  (stored time of last run)
#
# Main algorithm is daemon process runs every XX seconds, wakes up and
# looks for jobs. Jobs placed in the RunOncePeriodicJob queue are run 
# immediately (if no last_run_at time) and stored until they are cleaned up 
# (deleted). Jobs placed in the RunIntervalPeriodicJob queue are run if: 
# their last_run_at time + their interval (in seconds) is past the current 
# time (Time.now).
#

options = {}
ARGV.options do |opts|

  opts.on( "-e", "--environment ENVIRONMENT", String,
    "The Rails Environment to run under." ) do |environment|
    options[:environment] = environment
  end

  opts.parse!
end

RAILS_ENV = options[:environment] || 'development'  

require File.dirname(__FILE__) + '/../config/environment.rb'

if RAILS_ENV == "development" or RAILS_ENV == "test"
  SLEEP_TIME = 10
else
  SLEEP_TIME = 60
end

loop do
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
  
  sleep(SLEEP_TIME)
end