class AddImmediateTopicNotification < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :topic_notification_digests, :null => false, :default => true
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :topic_notification_digests
    end
  end
end
