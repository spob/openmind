require "migration_helpers"

class CreateTaskEstimate < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :task_estimates do |t|
      t.references :iteration, :null => false
      t.references :task, :null => true
      t.date :as_of, :null => false
      t.float :total_hours, :null => false
      t.float :remaining_hours, :null => false
      t.float :points_delivered, :null => true
      t.float :velocity, :null => true
      t.timestamps
    end
    add_foreign_key(:task_estimates, :iteration_id, :iterations)
    add_foreign_key(:task_estimates, :task_id, :tasks)
    add_index :task_estimates, [:iteration_id, :task_id, :as_of], :unique => true
    add_index :task_estimates, [:iteration_id, :as_of], :unique => false
    add_index :task_estimates, [:task_id, :as_of], :unique => false
  end

  def self.down
    remove_foreign_key(:task_estimates, :iteration_id)
    remove_foreign_key(:task_estimates, :task_id)
    drop_table :task_estimates
  end
end
