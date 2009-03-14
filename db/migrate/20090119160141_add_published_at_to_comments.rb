class AddPublishedAtToComments < ActiveRecord::Migration
  def self.up
    change_table :comments do |t|
      t.datetime :published_at
    end

    Comment.reset_column_information
    for comment in TopicComment.find(:all)
      comment.update_attribute(:published_at, comment.created_at) unless comment.private
    end
  end

  def self.down
    change_table :comments do |t|
      t.remove :published_at
    end
  end
end
