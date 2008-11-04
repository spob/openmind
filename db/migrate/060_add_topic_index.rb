class AddTopicIndex < ActiveRecord::Migration
  def self.up
    #    add_index :topics, [:forum_id], :unique => false
  end

  def self.down
    #    remove_index :topics, [:forum_id]
  end
end
