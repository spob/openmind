class AddTaskSchedulerBatch < ActiveRecord::Migration
  def self.up
    create_table :task_scheduler_batches do |t|
      t.integer :run_counter, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :task_scheduler_batches
  end
end
