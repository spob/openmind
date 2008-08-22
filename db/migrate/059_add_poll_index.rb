class AddPollIndex < ActiveRecord::Migration
  def self.up
    add_index :polls, :title, :unique => true
  end

  def self.down
    remove_index :polls, :title
  end
end
