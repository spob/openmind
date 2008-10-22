class AddPositionToLink < ActiveRecord::Migration
  def self.up
    change_table :links do |t|
      t.integer :position
    end
  end

  def self.down
    change_table :links do |t|
      t.remove :links
    end
  end
end
