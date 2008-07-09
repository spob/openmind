class AddTopicIdToComments < ActiveRecord::Migration
  def self.up
    add_column(:comments, :topic_id, :integer, :null => true)
    change_column(:comments, :idea_id, :integer, :null => true)
  end

  def self.down
    remove_column(:comments, :topic_id)
    change_column(:comments, :idea_id, :integer, :null => false)
  end
end
