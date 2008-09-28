class RunIntervalPeriodicJob < PeriodicJob
  before_create :set_next_run_at_date
  
  def calc_next_run
    begin
      #      puts "Calc next run #{Time.zone.now}, #{self.interval} #{(Time.zone.now + self.interval)}"
      return RunIntervalPeriodicJob.new(:job => self.job,
        :interval => self.interval,
        :next_run_at => (Time.zone.now + self.interval))
    
    rescue NoMethodError
      # Won't work if run during migration -- column is added later, so swallow it
      raise unless ActiveRecord::Migrator.current_version.to_i < 68
    end
  end
  
  def set_next_run_at_date
    self.next_run_at = Time.zone.now + self.interval
  end
end