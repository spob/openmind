class AddExternalPerId < ActiveRecord::Migration
  def self.up
    change_table :portal_user_org_maps do |t|
      t.string :external_per_id
    end
    add_index :portal_user_org_maps, :external_per_id, :unique => false
  end
  
  def self.down
    remove_index :portal_user_org_maps, :external_per_id
    change_table :portal_user_org_maps do |t|
      t.remove :external_per_id
    end
  end
end
