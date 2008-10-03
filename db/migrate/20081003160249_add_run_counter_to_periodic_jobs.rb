class AddRunCounterToPeriodicJobs < ActiveRecord::Migration
  def self.up
    change_table :periodic_jobs do |t|
      t.integer :run_counter
      t.index :run_counter
    end
  end

  def self.down
    change_table :periodic_jobs do |t|
      t.remove :run_counter
      t.remove_index :run_counter
    end
  end
end
