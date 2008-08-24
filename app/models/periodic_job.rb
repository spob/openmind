class PeriodicJob < ActiveRecord::Base

  # Runs a job and updates the +last_run_at+ field.
  def run!
    begin
      eval(self.job)
      self.last_run_result = "OK"
    rescue Exception
      err_string = "'#{self.job}' could not run: #{$!.message}\n#{$!.backtrace}" 
      logger.error err_string
      puts err_string 
      self.last_run_result = substr(err_string, 1, 500)
    end
    self.last_run_at = Time.now
    self.save  
  end

  def to_s
  	"#{self.class.to_s}: #{job}"
  end
end