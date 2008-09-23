class RunIntervalPeriodicJob < PeriodicJob
  before_create :calc_next_run
  
  def calc_next_run
    begin
    self.next_run_at = Time.zone.now + interval
    
    rescue NoMethodError
      # Won't work if run during migration -- column is added later, so swallow it
      raise unless ActiveRecord::Migrator.current_version.to_i < 68
    end
  end

  # RunIntervalPeriodicJobs run if PeriodicJob#last_run_at time plus 
  # PeriodicJob#interval (in seconds) is past the current time (Time.zone.now).
  def self.find_all_need_to_run
    self.find(:all).select {|job| job.last_run_at.nil? || 
        (job.last_run_at + job.interval <= Time.zone.now)}
  end
end