class PeriodicJob < ActiveRecord::Base
  before_create :set_initial_next_run
  
  def self.list(page, per_page)
    paginate :page => page, 
      :order => 'next_run_at DESC, last_run_at DESC',
      :per_page => per_page
  end
  
  def self.find_jobs_to_run
    PeriodicJob.find(:all, :conditions => ['next_run_at < ?',
      Time.zone.now.to_s(:db)], :order => "next_run_at ASC")
  end
  
  def self.run_jobs
    TaskServerLogger.instance.debug("Checking for periodic jobs to run...") if TaskServerLogger.instance.debug?
    PeriodicJob.find_jobs_to_run.each do |job|
      job.run!
    end
  end
  
  def calc_next_run
    nil
  end
  
  def can_delete?
    false  
  end
  
  def set_initial_next_run
    self.next_run_at = Time.zone.now
  end
  
  # Runs a job and updates the +last_run_at+ field.
  def run!
    TaskServerLogger.instance.info "Executing job id #{self.id}, #{self.to_s}..."
    begin
      eval(self.job)
      self.last_run_result = "OK"
      TaskServerLogger.instance.info "Job completed successfully"
    rescue Exception
      err_string = "'#{self.job}' could not run: #{$!.message}\n#{$!.backtrace}" 
      TaskServerLogger.instance.error err_string
      puts err_string 
      self.last_run_result = err_string.slice(1..500)
    end
    self.last_run_at = Time.zone.now
    self.next_run_at = self.calc_next_run
    self.save  
  end

  def to_s
    "#{self.class.to_s}: #{job}"
  end
end