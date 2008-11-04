require "migration_helpers"

class AddTopicIdToComments < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :comments do |t|
      t.references :topic, :null => true
    end
    change_column(:comments, :idea_id, :integer, :null => true, :default => nil)
    
    add_foreign_key(:comments, :topic_id, :topics)
  end

  def self.down
    execute "Delete from comments where type = 'TopicComment'"
#    for comment in TopicComment.find(:all)
#      comment.destroy
#    end
    
    remove_column(:comments, :topic_id)
    change_column(:comments, :idea_id, :integer, :null => false)
  end
end
