class AddLinkSetLabel < ActiveRecord::Migration
  def self.up
    change_table :link_sets do |t|
      t.string :label, :limit => 30, :null => false
    end
  end

  def self.down
    change_table :link_sets do |t|
      t.remove :label
    end
  end
end
