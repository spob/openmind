class RunAtPeriodicJob < PeriodicJob
  before_create :set_next_run
  validates_presence_of :run_at_minutes
  
  def calc_next_run
    RunAtPeriodicJob.new(:job => self.job,
      :run_at_minutes => self.run_at_minutes)
  end
  
  def set_next_run
    begin
      self.next_run_at = calc_next_run_at_date
    
    rescue NoMethodError
      # Won't work if run during migration -  - column is added later, so swallow it
      raise unless ActiveRecord::Migrator.current_version.to_i < 68
    end
  end
  
  private
  
  def calc_next_run_at_date
    begin
      # has it run at the appointed time for today
      hours = self.run_at_minutes/60
      minutes = self.run_at_minutes - hours * 60
        
      if DateTime.now.hour * 60 + DateTime.now.min < run_at_minutes
        self.next_run_at = Time.local(Time.now.year, Time.now.month, Time.now.day, hours, minutes, 0)
      else
        self.next_run_at = Time.local(Time.now.year, Time.now.month, Time.now.day + 1, hours, minutes, 0)
      end
    
    rescue NoMethodError
      # Won't work if run during migration -- column is added later, so swallow it
      raise unless ActiveRecord::Migrator.current_version.to_i < 68
    end
  end
end