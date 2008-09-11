class AddNextRunAt < ActiveRecord::Migration
  def self.up
    add_column :periodic_jobs, :next_run_at, :datetime, :null => true
  end

  def self.down
    remove_column :periodic_jobs, :next_run_at
  end
end
