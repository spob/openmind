class AddCommentCount < ActiveRecord::Migration
  def self.up
    add_column :topics, :topic_comments_count, :integer, :default => 0
    
    Topic.reset_column_information
    Topic.find(:all).each do |t|
      t.update_attribute :topic_comments_count, t.comments.length
    end
  end

  def self.down
    remove_column :topics, :topic_comments_count
  end
end
