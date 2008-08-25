class CreateGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :group_members, :id => false  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :group_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :group_members
  end
end
