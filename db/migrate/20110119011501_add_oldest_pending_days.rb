class AddOldestPendingDays < ActiveRecord::Migration
  def self.up
    change_table :forum_metrics do |t|
      t.decimal :oldest_pending_days
    end
  end

  def self.down
    change_table :forum_metrics do |t|
      t.remove :oldest_pending_days
    end
  end
end
