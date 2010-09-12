require "migration_helpers"

class CreatePortalCustomers < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :portal_customers do |t|
      t.references :portal_org, :null => false
      t.string :location
      t.string :serial_number
      t.datetime :registered_at
      t.string :registered_version
      t.datetime :maintenance_expires_at
      t.string :product
      t.boolean :available
      t.timestamps
    end
    add_foreign_key(:portal_customers, :portal_org_id, :portal_orgs)
    add_index :portal_certified_consultants, [:portal_org_id, :serial_number], :unique => true
  end

  def self.down
    remove_foreign_key(:portal_customers, :portal_org_id)
    drop_table :portal_customers
  end
end
