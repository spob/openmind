class CreatePeriodicJobs < ActiveRecord::Migration
  def self.up
    create_table :periodic_jobs do |t|
      t.column :type, :string
      t.column :job, :text
      t.column :interval, :integer
      t.column :last_run_at, :datetime
      t.column :run_at_minutes, :integer
    end
    
    
    PeriodicJob.reset_column_information
#    RunIntervalPeriodicJob.create(:job => 'puts "This job runs every 30 seconds, and it ran: #{Time.now}"', :interval => 30)
    RunAtPeriodicJob.create(:job => 'puts "This job runs at 3AM, and it ran: #{Time.now}"', :run_at_minutes => 180)
  end

  def self.down
    drop_table :periodic_jobs
  end
end
