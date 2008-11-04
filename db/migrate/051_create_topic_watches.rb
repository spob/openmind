require "migration_helpers"

class CreateTopicWatches < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :topic_watches  do |t|
      t.references :user, :null => false
      t.references :topic, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_foreign_key(:topic_watches, :user_id, :users)
    add_foreign_key(:topic_watches, :topic_id, :topics)
    
    add_index :topic_watches, [:user_id, :topic_id], :unique => true
  end

  def self.down
    drop_table :topic_watches
  end
end
