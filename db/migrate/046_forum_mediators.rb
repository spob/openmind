require "migration_helpers"

class ForumMediators < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :forum_mediators, :id => false  do |t|
      t.references :user,  :null => false
      t.references :forum,  :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:forum_mediators, :user_id, :users)
    add_foreign_key(:forum_mediators, :forum_id, :forums)
  end

  def self.down
    drop_table :forum_mediators
  end
end
