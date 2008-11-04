require "migration_helpers"

class AddPollIdToComment < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :comments do |t|
      t.references :poll, :null => true  
    end
    
    add_foreign_key(:comments, :poll_id, :polls)
    
    change_table :polls do |t|
      t.integer :poll_comments_count, :default => 0
    end
  end

  def self.down
    change_table :comments do |t|
      t.remove :poll_id
    end
    change_table :polls do |t|
      t.remove :poll_comments_count
    end
  end
end
