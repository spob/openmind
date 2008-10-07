class TouchCounter < ActiveRecord::Migration
  def self.up
    change_table :topics do |t|
      t.integer :touch_counter, :default => 0, :null => false
    end
  end

  def self.down
    change_table :topics do |t|
      t.remove :touch_counter
    end
  end
end
