require "migration_helpers"

class AddIdeaChangeLog < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :idea_change_logs do |t|
      t.references :idea, :null => false
      t.references :user, :null => false
      t.text :message, :null => false
      t.datetime :processed_at, :null => true
      t.timestamps
    end
    
    add_foreign_key(:idea_change_logs, :idea_id, :ideas)
    add_foreign_key(:idea_change_logs, :user_id, :users)
  end

  def self.down
    drop_table :idea_change_logs
  end
end
