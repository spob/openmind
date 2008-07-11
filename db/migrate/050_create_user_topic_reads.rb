class CreateUserTopicReads < ActiveRecord::Migration
  def self.up
    create_table :user_topic_reads  do |t|
      t.column :user_id,  :integer, :null => false
      t.column :topic_id,  :integer, :null => false
      t.column :lock_version, :integer, :default => 0
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :views,  :integer, :null => false, :default => 0
    end
    add_index :user_topic_reads, :user_id, :unique => false
    add_index :user_topic_reads, :topic_id, :unique => false
  end

  def self.down
    drop_table :user_topic_reads
  end
end
