class PeriodicJobCleanup < ActiveRecord::Migration
  def self.up
    RunIntervalPeriodicJob.reset_column_information
    # Clean up old Periodic_job_cleanup
    for job in RunIntervalPeriodicJob.find_all_by_job('RunOncePeriodicJob.cleanup')
      job.destroy
    end
    # Cleans up periodic jobs, removes all RunOncePeriodicJobs over one
    # day old.    
    RunIntervalPeriodicJob.create(:job => 'PeriodicJob.cleanup', :interval => 3600) #once an hour
  end

  def self.down
  end
end
