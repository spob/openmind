require "migration_helpers"

class CreatePortalUserOrgMaps < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :portal_user_org_maps do |t|
      t.string :email, :null => false
      t.string :org_name, :null => false
      t.string :external_org_id, :null => false
      t.references :portal_org, :null => false
      t.timestamps
    end
    add_foreign_key(:portal_user_org_maps, :portal_org_id, :portal_orgs)
    add_index :portal_user_org_maps, [:email, :external_org_id], :unique => true
  end

  def self.down
    remove_foreign_key(:portal_user_org_maps, :portal_org_id)
    drop_table :portal_user_org_maps
  end
end
