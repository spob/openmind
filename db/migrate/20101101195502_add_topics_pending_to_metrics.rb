class AddTopicsPendingToMetrics < ActiveRecord::Migration
  def self.up
    change_table :forum_metrics do |t|
      t.integer :pending_count, :null => false, :default => 0
    end
  end

  def self.down
    change_table :forum_metrics do |t|
      t.remove :pending_count
    end
  end
end
