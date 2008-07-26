class RemoveUpdatedAtOnRolesUsers < ActiveRecord::Migration
  def self.up
    remove_column :roles_users, :updated_at
  end

  def self.down
    add_column :roles_users, :updated_at, :datetime, 
      :default => Time.now.to_s(:db), :null => false
  end
end
