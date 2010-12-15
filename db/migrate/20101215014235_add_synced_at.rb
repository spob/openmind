class AddSyncedAt < ActiveRecord::Migration
  def self.up
    change_table :iterations do |t|
      t.timestamp :last_synced_at, :null => true
    end
  end

  def self.down
    change_table :iterations do |t|
      t.remove :last_synced_at
    end
  end
end
