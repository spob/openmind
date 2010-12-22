require "migration_helpers"

class CreatePortalEntitlements < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :portal_entitlements do |t|
      t.references :portal_org, :null => false
      t.integer :entitlements_total, :null => false
      t.integer :entitlements_available, :null => false
      t.integer :entitlements_used, :null => false
      t.integer :purchased_entitlements_total, :null => false
      t.integer :purchased_entitlements_available, :null => false
      t.integer :purchased_entitlements_used, :null => false
      t.timestamps
    end
    add_foreign_key(:portal_entitlements, :portal_org_id, :portal_orgs)
  end

  def self.down
    remove_foreign_key(:portal_entitlements, :portal_org_id)
    drop_table :portal_entitlements
  end
end
