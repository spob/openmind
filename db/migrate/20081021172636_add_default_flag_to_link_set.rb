class AddDefaultFlagToLinkSet < ActiveRecord::Migration
  def self.up
    change_table :link_sets do |t|
      t.boolean :default_link_set, :default => false, :null => false
    end
  end

  def self.down
    change_table :link_sets do |t|
      t.remove :default_link_set
    end
  end
end
