class CreatePortalOrgs < ActiveRecord::Migration
  
  def self.up
    create_table :portal_orgs do |t|
      t.string :external_org_id, :null => false
      t.string :org_name
      t.timestamps
    end
    add_index :portal_orgs, [:external_org_id], :unique => true
  end

  def self.down
    drop_table :portal_orgs
  end
end
