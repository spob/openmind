require "migration_helpers"

class CreateTasks < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :tasks do |t|
      t.integer :pivotal_identifier
      t.references :story, :null => false
      t.string :description
      t.float :total_hours
      t.float :remaining_hours
      t.string :status

      t.timestamps
    end
    add_foreign_key(:tasks, :story_id, :stories)
    add_index :tasks, [:pivotal_identifier], :unique => true
  end

  def self.down
    remove_foreign_key(:tasks, :story_id)
    drop_table :tasks
  end
end
