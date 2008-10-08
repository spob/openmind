class AddForumActiveFlag < ActiveRecord::Migration
  def self.up
    change_table :forums do |t|
      t.boolean :active, :default => true, :null => false
    end
  end

  def self.down
    change_table :forums do |t|
      t.remove :active
    end
  end
end
