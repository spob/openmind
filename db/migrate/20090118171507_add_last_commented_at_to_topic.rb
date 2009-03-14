class AddLastCommentedAtToTopic < ActiveRecord::Migration
  def self.up
    change_table :topics do |t|
      t.datetime :last_commented_at
    end

    Topic.reset_column_information
    for topic in Topic.find(:all)
      topic.update_attribute(:last_commented_at, topic.updated_at)
    end
  end

  def self.down
    change_table :topics do |t|
      t.remove :last_commented_at
    end
  end
end
