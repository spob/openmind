require "migration_helpers"

class CreateForumWatch < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :forum_watches, :id => false  do |t|
      t.references :user, :null => false
      t.references :forum, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:forum_watches, :user_id, :users)
    add_foreign_key(:forum_watches, :forum_id, :forums)
    
    add_index :forum_watches, [:user_id, :forum_id], :unique => false
  end

  def self.down
    remove_foreign_key(:forum_watches, :user_id)
    remove_foreign_key(:forum_watches, :forum_id)
    
    drop_table :forum_watches
  end
end
