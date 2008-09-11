class RunIntervalPeriodicJob < PeriodicJob
  before_create :calc_next_run
  
  def calc_next_run
    self.next_run_at = Time.now + interval
  end

  # RunIntervalPeriodicJobs run if PeriodicJob#last_run_at time plus 
  # PeriodicJob#interval (in seconds) is past the current time (Time.now).
  def self.find_all_need_to_run
    self.find(:all).select {|job| job.last_run_at.nil? || 
        (job.last_run_at + job.interval <= Time.now)}
  end
end