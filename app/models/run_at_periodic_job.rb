# == Schema Information
# Schema version: 20081021172636
#
# Table name: periodic_jobs
#
#  id              :integer(4)      not null, primary key
#  type            :string(255)
#  job             :text
#  interval        :integer(4)
#  last_run_at     :datetime
#  run_at_minutes  :integer(4)
#  last_run_result :string(500)
#  next_run_at     :datetime
#  run_counter     :integer(4)
#

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
        
      if Time.zone.now.hour * 60 + Time.zone.now.min < run_at_minutes
        self.next_run_at = Time.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, hours, minutes, 0)
      else
        self.next_run_at = Time.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, hours, minutes, 0) + 
          1.day
      end
    
    rescue NoMethodError
      # Won't work if run during migration -- column is added later, so swallow it
      raise unless ActiveRecord::Migrator.current_version.to_i < 68
    end
  end
end
