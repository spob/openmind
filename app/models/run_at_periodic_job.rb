class RunAtPeriodicJob < PeriodicJob
  before_create :set_initial_next_run
  validates_presence_of :run_at_minutes
  
  def calc_next_run
    # has it run at the appointed time for today
    hours = self.run_at_minutes/60
    minutes = self.run_at_minutes - hours * 60
        
    if DateTime.now.hour * 60 + DateTime.now.min < run_at_minutes
      self.next_run_at = Time.local(Time.now.year, Time.now.month, Time.now.day, hours, minutes, 0)
    else
      self.next_run_at = Time.local(Time.now.year, Time.now.month, Time.now.day + 1, hours, minutes, 0)
    end
  end
  
  def set_initial_next_run
    self.next_run_at = Time.now
  end

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