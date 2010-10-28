require "migration_helpers"

class CreatePortalSupportIncidents < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :portal_support_incidents do |t|
      t.references :portal_org, :null => false
      t.string :case_number, :null => false
      t.datetime :opened_at
      t.datetime :closed_at
      t.string :serial_number
      t.string :summary
      t.string :opened_by
      t.string :customer
      t.boolean :is_billable
      t.boolean :within_sla
      t.timestamps
    end
    add_foreign_key(:portal_support_incidents, :portal_org_id, :portal_orgs)
    add_index :portal_support_incidents, [:portal_org_id, :case_number], :unique => true
  end

  def self.down
    remove_foreign_key(:portal_support_incidents, :portal_org_id)
    drop_table :portal_support_incidents
  end
end
