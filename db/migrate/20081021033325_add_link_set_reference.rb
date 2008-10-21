class AddLinkSetReference < ActiveRecord::Migration
  def self.up
    change_table :forums do |t|
      t.references :link_set, :null => true
    end
  end

  def self.down
    change_table :forums do |t|
      t.remove :link_set_id
    end
  end
end
