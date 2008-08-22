class CreateUsersRoles < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :role_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
    
    add_index :roles_users, [:user_id, :role_id], :unique => true
  end

  def self.down
    drop_table :roles_users
  end
end
