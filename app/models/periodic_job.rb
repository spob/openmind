class PeriodicJob < ActiveRecord::Base
  
  def self.list(page, per_page)
    paginate :page => page, 
      :order => 'next_run_at DESC, last_run_at DESC',
      :per_page => per_page
  end
  
  def calc_next_run
    throw exception
  end
  
  def can_delete?
    false  
  end
  
  # Runs a job and updates the +last_run_at+ field.
  def run!
    begin
      eval(self.job)
      self.last_run_result = "OK"
    rescue Exception
      err_string = "'#{self.job}' could not run: #{$!.message}\n#{$!.backtrace}" 
      logger.error err_string
      puts err_string 
      self.last_run_result = err_string.slice(1..500)
    end
    self.last_run_at = Time.zone.now
    self.calc_next_run
    self.save  
  end

  def to_s
    "#{self.class.to_s}: #{job}"
  end
end