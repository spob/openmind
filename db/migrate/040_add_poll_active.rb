class AddPollActive < ActiveRecord::Migration
  def self.up
    add_column :polls, :active,  :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :polls, :active
  end
end
