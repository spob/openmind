class ForumMediators < ActiveRecord::Migration
  def self.up
    create_table :forum_mediators, :id => false  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :forum_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :forum_mediators
  end
end
