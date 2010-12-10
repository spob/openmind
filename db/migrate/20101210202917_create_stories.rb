require "migration_helpers"

class CreateStories < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :stories do |t|
      t.integer :pivotal_id
      t.references :iteration, :null => false
      t.string :story_type
      t.string :url
      t.integer :points
      t.string :status
      t.string :name
      t.string :owner

      t.timestamps
    end
    add_foreign_key(:stories, :iteration_id, :iterations)
  end

  def self.down
    remove_foreign_key(:stories, :iteration_id)
    drop_table :stories
  end
end
