class AddRestrictTopicCreation < ActiveRecord::Migration
  def self.up
    change_table :forums do |t|
      t.boolean :restrict_topic_creation, :default => false, :null => false
    end
  end

  def self.down
    change_table :forums do |t|
      t.remove :restrict_topic_creation
    end
  end
end
