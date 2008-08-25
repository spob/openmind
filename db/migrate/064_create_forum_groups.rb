class CreateForumGroups < ActiveRecord::Migration
  def self.up
    create_table :forums_groups, :id => false  do |t|
      t.column :forum_id,  :integer, :null => false
      t.column :group_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
    add_index :forums_groups, [:forum_id, :group_id], :unique => true
  end

  def self.down
    drop_table :forums_groups
  end
end
