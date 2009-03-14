class CreatePeriodicJobs < ActiveRecord::Migration
  def self.up
    create_table :periodic_jobs, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :type, :string
      t.column :job, :text
      t.column :interval, :integer
      t.column :last_run_at, :datetime
      t.column :run_at_minutes, :integer
    end
    
    
    PeriodicJob.reset_column_information
    # Send email on new topic comments
    #    RunIntervalPeriodicJob.create(:job => 'Topic.notify_watchers', :interval => 30)
    RunAtPeriodicJob.create(:job => 'Topic.notify_watchers', :run_at_minutes => 180) # run at 6AM
    #
    #
    # Cleans up periodic jobs, removes all RunOncePeriodicJobs over one
    # day old.    
    RunIntervalPeriodicJob.create(:job => 'RunOncePeriodicJob.cleanup', :interval => 3600) #once an hour
  end

  def self.down
    drop_table :periodic_jobs
  end
end
