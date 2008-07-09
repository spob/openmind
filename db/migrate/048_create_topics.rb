class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.column :title, :string, :limit => 120, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :forum_id,  :integer, :null => false
      t.column :user_id,  :integer, :null => false
      t.column :pinned, :boolean, :default => false, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
    add_index :topics, :title, :unique => false
  end

  def self.down
    drop_table :topics
  end
end
