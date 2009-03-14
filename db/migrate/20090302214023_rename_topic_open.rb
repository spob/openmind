class RenameTopicOpen < ActiveRecord::Migration
  def self.up
    rename_column "topics", "open", "open_status"
  end

  def self.down
    rename_column "topics", "open_status", "open"
  end
end
