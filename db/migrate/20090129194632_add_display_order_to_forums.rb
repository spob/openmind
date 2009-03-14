class AddDisplayOrderToForums < ActiveRecord::Migration
  def self.up
    change_table :forums do |t|
      t.integer :display_order, :default => 10, :null => true
    end
  end

  def self.down
    change_table :forums do |t|
      t.remove :display_order
    end
  end
end