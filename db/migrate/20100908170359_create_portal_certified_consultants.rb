require "migration_helpers"

class CreatePortalCertifiedConsultants < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :portal_certified_consultants do |t|
      t.references :portal_org, :null => false
      t.string :consultant_type, :null => false
      t.string :consultant_name, :null => false
      t.string :consultant_email
      t.string :certification
      t.datetime :certified_at
      t.string :is_active
      t.boolean :purchased_training
      t.timestamps
    end
    add_foreign_key(:portal_certified_consultants, :portal_org_id, :portal_orgs)
    add_index :portal_certified_consultants, [:portal_org_id, :consultant_type, :consultant_email], 
    :name => ':portal_certified_consultants_u1', :unique => true
  end
  
  def self.down
    remove_foreign_key(:portal_certified_consultants, :portal_org_id)
    drop_table :portal_certified_consultants
  end
end
