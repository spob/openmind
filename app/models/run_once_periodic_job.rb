class RunOncePeriodicJob < PeriodicJob
  before_create :set_initial_next_run

  # RunOncePeriodicJobs run if they have no PeriodicJob#last_run_at time.
  def self.find_all_need_to_run
    TaskServerLogger.instance.debug("Checking for RunOncePeriodicJob jobs to be run...")
    self.find(:all, :conditions => ["last_run_at IS NULL"])
  end
  
  def calc_next_run
    self.next_run_at = nil
  end
  
  def set_initial_next_run
    self.next_run_at = Time.zone.now
  end

  # Cleans up all jobs older than a day.
  def self.cleanup
    self.destroy_all ['last_run_at < ?', 7.day.ago]
  end
end