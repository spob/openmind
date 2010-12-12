require "migration_helpers"

class CreateStories < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :stories do |t|
      t.integer :pivotal_identifier
      t.references :iteration, :null => false
      t.string :story_type, :null => false
      t.string :url, :null => false
      t.integer :points
      t.string :status, :null => false
      t.string :name, :null => false
      t.string :owner

      t.timestamps
    end
    add_foreign_key(:stories, :iteration_id, :iterations)
    add_index :stories, [:pivotal_identifier], :unique => true
  end

  def self.down
    remove_foreign_key(:stories, :iteration_id)
    drop_table :stories
  end
end
