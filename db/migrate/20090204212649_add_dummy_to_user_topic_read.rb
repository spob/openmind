class AddDummyToUserTopicRead < ActiveRecord::Migration
  def self.up
    change_table :user_topic_reads do |t|
      t.integer :dummy, :default => 1, :null => false
    end
  end

  def self.down
    change_table :user_topic_reads do |t|
      t.remove :dummy
    end
  end
end
