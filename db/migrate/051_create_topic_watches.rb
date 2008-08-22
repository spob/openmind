class CreateTopicWatches < ActiveRecord::Migration
  def self.up
    create_table :topic_watches  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :topic_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
    end
    
    add_index :topic_watches, [:user_id, :topic_id], :unique => true
  end

  def self.down
    drop_table :topic_watches
  end
end
