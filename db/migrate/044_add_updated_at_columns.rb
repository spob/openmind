class AddUpdatedAtColumns < ActiveRecord::Migration
  def self.up
    add_column :announcements, :updated_at, :datetime, :null => true
    add_column :enterprises, :updated_at, :datetime, :null => true
    add_column :lookup_codes, :updated_at, :datetime, :null => true
    add_column :poll_options, :updated_at, :datetime, :null => true
    add_column :polls, :updated_at, :datetime, :null => true
    add_column :products, :updated_at, :datetime, :null => true
    add_column :releases, :updated_at, :datetime, :null => true
    add_column :roles, :updated_at, :datetime, :null => true
    add_column :roles_users, :updated_at, :datetime, :null => true
    
    execute "update announcements set updated_at = now() where updated_at is null"
    execute "update enterprises set updated_at = now() where updated_at is null"
    execute "update lookup_codes set updated_at = now() where updated_at is null"
    execute "update poll_options set updated_at = now() where updated_at is null"
    execute "update polls set updated_at = now() where updated_at is null"
    execute "update products set updated_at = now() where updated_at is null"
    execute "update releases set updated_at = now() where updated_at is null"
    execute "update roles set updated_at = now() where updated_at is null"
    execute "update roles_users set updated_at = now() where updated_at is null"
    
    change_column :announcements, :updated_at, :datetime, :null => false
    change_column :enterprises, :updated_at, :datetime, :null => false
    change_column :lookup_codes, :updated_at, :datetime, :null => false
    change_column :poll_options, :updated_at, :datetime, :null => false
    change_column :polls, :updated_at, :datetime, :null => false
    change_column :products, :updated_at, :datetime, :null => false
    change_column :polls, :updated_at, :datetime, :null => false
    change_column :roles, :updated_at, :datetime, :null => false
    change_column :roles_users, :updated_at, :datetime, :null => false
  end

  def self.down
    remove_column :announcements, :updated_at
    remove_column :enterprises, :updated_at
    remove_column :lookup_codes, :updated_at
    remove_column :poll_options, :updated_at
    remove_column :polls, :updated_at
    remove_column :products, :updated_at
    remove_column :roles, :updated_at
    remove_column :roles_users, :updated_at
  end
end
