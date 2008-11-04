require "migration_helpers"

class CreateForumGroups < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :forums_groups, :id => false  do |t|
      t.references :forum, :null => false
      t.references :group, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:forums_groups, :forum_id, :forums)
    add_foreign_key(:forums_groups, :group_id, :groups)
    
    add_index :forums_groups, [:forum_id, :group_id], :unique => true
  end

  def self.down
    drop_table :forums_groups
  end
end
