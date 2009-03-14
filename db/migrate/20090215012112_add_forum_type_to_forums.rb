class AddForumTypeToForums < ActiveRecord::Migration
  def self.up
    change_table :forums do |t|
      t.string :forum_type, :default => 'forum', :null => false
    end
    Forum.reset_column_information

    for forum in Forum.find(:all)
      forum.forum_type = 'blog' if forum.restrict_topic_creation
      forum.save!
    end
    change_table :forums do |t|
      t.remove :restrict_topic_creation
    end
  end

  def self.down
    change_table :forums do |t|
      t.boolean :restrict_topic_creation, :default => false, :null => false
    end
    Forum.reset_column_information
    for forum in Forum.find(:all)
      forum.restrict_topic_creation = true if forum.forum_type != 'forum'
      forum.save!
    end
    change_table :forums do |t|
      t.remove :forum_type
    end
  end
end
