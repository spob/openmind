require "migration_helpers"

class CreateRolesUserRequests < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :roles_user_requests, :id => false  do |t|
      t.references :user_request, :null => false
      t.references :role,  :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:roles_user_requests, :user_request_id, :user_requests)
    add_foreign_key(:roles_user_requests, :role_id, :roles)
    
    add_index :roles_user_requests, [:user_request_id, :role_id], :unique => true
  end

  def self.down
    remove_foreign_key(:roles_user_requests, :user_request_id)
    remove_foreign_key(:roles_user_requests, :role_id)
    
    drop_table :roles_user_requests
  end
end
