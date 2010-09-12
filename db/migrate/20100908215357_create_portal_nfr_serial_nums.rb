require "migration_helpers"

class CreatePortalNfrSerialNums < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :portal_nfrs do |t|
      t.references :portal_org, :null => false
      t.string :product
      t.string :serial_number
      t.datetime :expires_at
      t.string :registered_to
      t.timestamps
    end
    add_foreign_key(:portal_nfrs, :portal_org_id, :portal_orgs)
    add_index :portal_nfrs, [:portal_org_id, :serial_number], :unique => true
  end
  
  def self.down
    remove_foreign_key(:portal_nfrs, :portal_org_id)
    drop_table :portal_nfrs
  end
end
