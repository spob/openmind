require "migration_helpers"

class CreateIterations < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :iterations do |t|
      t.integer :iteration_number, :null => false
      t.references :project, :null => false
      t.date    :start_on, :null => false
      t.date    :end_on, :null => false
    end
    
    add_foreign_key(:iterations, :project_id, :projects)
    add_index :iterations, [:iteration_number], :unique => false
  end

  def self.down
    remove_foreign_key(:iterations, :project_id)
    drop_table :iterations
  end
end
