require "migration_helpers"

class CreateGroupsUserRequests < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :groups_user_requests, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8', :id => false  do |t|
      t.references :user_request, :null => false
      t.references :group,  :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:groups_user_requests, :user_request_id, :user_requests)
    add_foreign_key(:groups_user_requests, :group_id, :groups)
    
    add_index :groups_user_requests, [:user_request_id, :group_id], :unique => true
  end

  def self.down
#    remove_foreign_key(:groups_user_requests, :user_request_id)
#    remove_foreign_key(:groups_user_requests, :group_id)
    
    drop_table :groups_user_requests
  end
end
