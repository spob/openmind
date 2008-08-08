class CreateUserTable < ActiveRecord::Migration
  def self.up
    add_column(:users, :watch_on_vote, :boolean, :default => true, :null => false)
  end

  def self.down
    remove_column :users, :watch_on_vote
  end
end
