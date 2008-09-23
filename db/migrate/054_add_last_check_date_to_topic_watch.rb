class AddLastCheckDateToTopicWatch < ActiveRecord::Migration
  def self.up
    add_column :topic_watches, :last_checked_at, :datetime, 
      :default => Time.zone.now.to_s(:db), :null => false
  end

  def self.down
    remove_column :topic_watches, :last_checked_at
  end
end
