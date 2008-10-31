class AddPublicallyVisible < ActiveRecord::Migration
  def self.up
    change_table :polls do |t|
      t.boolean :results_publically_visible, :default => true, :null => false
    end
  end

  def self.down
    change_table :polls do |t|
      t.remove :results_publically_visible
    end
  end
end
