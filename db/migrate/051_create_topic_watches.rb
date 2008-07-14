class CreateTopicWatches < ActiveRecord::Migration
  def self.up
    create_table :topic_watches, :id => false  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :topic_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
    
    add_index :topic_watches, :user_id, :unique => false
    add_index :topic_watches, :topic_id, :unique => false
  end

  def self.down
    drop_table :topic_watches
  end
end
