class RunAtPeriodicJob < PeriodicJob
  validates_presence_of :run_at_minutes

  # RunIntervalPeriodicJobs run if PeriodicJob#last_run_at time plus 
  # PeriodicJob#interval (in seconds) is past the current time (Time.now).
  def self.find_all_need_to_run
    self.find(:all).select {|job| 
      lastrun = DateUtils.time_to_datetime(job.last_run_at)
      job.last_run_at.nil? || # it's never run
         (DateTime.now.jd - lastrun.jd == 1 && # or it ran yesterday and it's past the run at time
             DateTime.now.hour * 60 + DateTime.now.min > job.run_at_minutes) || 
         (DateTime.now.jd - lastrun.jd > 1) # or ran more than a day ago
         }
  end
end