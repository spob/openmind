class CreateGroupsUserRequests < ActiveRecord::Migration
  def self.up
    create_table :groups_user_requests, :id => false  do |t|
      t.references :user_request, :null => false
      t.references :group,  :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    add_index :groups_user_requests, [:user_request_id, :group_id], :unique => true
  end

  def self.down
    drop_table :groups_user_requests
  end
end
