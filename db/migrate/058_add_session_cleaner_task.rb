class AddSessionCleanerTask < ActiveRecord::Migration
  def self.up
    RunIntervalPeriodicJob.create(:job => 'SessionCleaner.clean', 
      :interval => 3600 * 24) #once a day
  end

  def self.down
    RunIntervalPeriodicJob.find_by_job("SessionCleaner.clean").destroy
  end
end
