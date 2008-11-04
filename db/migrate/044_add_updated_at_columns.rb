class AddUpdatedAtColumns < ActiveRecord::Migration
  def self.up
    #    add_column :announcements, :updated_at, :datetime, :null => true
    #    add_column :poll_options, :updated_at, :datetime, :null => true
    #    add_column :polls, :updated_at, :datetime, :null => true
    # 
    #    execute "update announcements set updated_at = now() where updated_at is null"
    #    execute "update poll_options set updated_at = now() where updated_at is null"
    #    execute "update polls set updated_at = now() where updated_at is null"
    # 
    #    change_column :announcements, :updated_at, :datetime, :null => false
    #    change_column :poll_options, :updated_at, :datetime, :null => false
    #    change_column :polls, :updated_at, :datetime, :null => false
  end

  def self.down
    #    remove_column :announcements, :updated_at
    #    remove_column :poll_options, :updated_at
    #    remove_column :polls, :updated_at
  end
end
