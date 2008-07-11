class AddTopicIdToComments < ActiveRecord::Migration
  def self.up
    add_column(:comments, :topic_id, :integer, :null => true)
    change_column(:comments, :idea_id, :integer, :null => true, :default => nil)
    
    add_index :comments, :topic_id, :unique => false
  end

  def self.down
    for comment in TopicComment.find(:all)
      comment.destroy
    end
    remove_index :comments, :topic_id
    
    remove_column(:comments, :topic_id)
    change_column(:comments, :idea_id, :integer, :null => false)
  end
end
