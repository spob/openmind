require "migration_helpers"

class CreateUsersRoles < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :roles_users, :id => false  do |t|
      t.references :user, :null => false
      t.references :role,  :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_index :roles_users, [:user_id, :role_id], :unique => true
    
    add_foreign_key(:roles_users, :user_id, :users)
    add_foreign_key(:roles_users, :role_id, :roles)
  end

  def self.down
    remove_foreign_key(:roles_users, :user_id)
    remove_foreign_key(:roles_users, :role_id)
    
    drop_table :roles_users
  end
end
