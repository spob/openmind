class RunOncePeriodicJob < PeriodicJob

  # RunOncePeriodicJobs run if they have no PeriodicJob#last_run_at time.
  def self.find_all_need_to_run
    self.find(:all, :conditions => ["last_run_at IS NULL"])
  end

  # Cleans up all jobs older than a day.
  def self.cleanup
    self.destroy_all ['last_run_at < ?', 1.day.ago]
  end

end