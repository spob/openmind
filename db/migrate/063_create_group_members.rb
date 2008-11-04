require "migration_helpers"

class CreateGroupMembers < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :group_members, :id => false  do |t|
      t.references :user, :null => false
      t.references :group, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:group_members, :user_id, :users)
    add_foreign_key(:group_members, :group_id, :groups)
    
    add_index :group_members, [:user_id, :group_id], :unique => true
  end

  def self.down
    drop_table :group_members
  end
end
