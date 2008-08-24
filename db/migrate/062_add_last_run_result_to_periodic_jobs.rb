class AddLastRunResultToPeriodicJobs < ActiveRecord::Migration
  def self.up
    add_column(:periodic_jobs, :last_run_result, :string, :limit => 500, :null => true)
  end

  def self.down
    remove_column :periodic_jobs, :last_run_result
  end
end
