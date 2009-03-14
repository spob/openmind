require "migration_helpers"

class CreateUserTopicReads < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :user_topic_reads, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8'  do |t|
      t.references :user, :null => false
      t.references :topic, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
      t.column :views,  :integer, :null => false, :default => 0
    end
    
    add_foreign_key(:user_topic_reads, :user_id, :users)
    add_foreign_key(:user_topic_reads, :topic_id, :topics)
    
    add_index :user_topic_reads, [:user_id, :topic_id], :unique => true
  end

  def self.down
    remove_foreign_key(:user_topic_reads, :user_id)
    remove_foreign_key(:user_topic_reads, :topic_id)
    
    drop_table :user_topic_reads
  end
end
