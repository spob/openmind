class CreateForumWatch < ActiveRecord::Migration
  def self.up
    create_table :forum_watches, :id => false  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :forum_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
    
    add_index :forum_watches, :user_id, :unique => false
    add_index :forum_watches, :forum_id, :unique => false
  end

  def self.down
    drop_table :forum_watches
  end
end
