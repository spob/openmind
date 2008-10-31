class CreateRolesUserRequests < ActiveRecord::Migration
  def self.up
    create_table :roles_user_requests, :id => false  do |t|
      t.references :user_request, :null => false
      t.references :role,  :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    add_index :roles_user_requests, [:user_request_id, :role_id], :unique => true
  end

  def self.down
    drop_table :roles_user_requests
  end
end
