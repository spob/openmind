require "migration_helpers"

class AddTrackingToTopics < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :forums do |t|
      t.boolean :tracked, :default => false, :null => false
    end
    change_table :topics do |t|
      t.boolean :open, :default => true, :null => false
      t.column :owner_id, :integer, :null => true, :references => :user
      t.datetime :closed_at
    end
    add_foreign_key(:topics, :owner_id, :users)
  end

  def self.down
    remove_foreign_key(:topics, :owner_id)
    change_table :forums do |t|
      t.remove :tracked
    end
    change_table :topics do |t|
      t.remove :open
      t.remove :owner_id
      t.remove :closed_at
    end
  end
end
