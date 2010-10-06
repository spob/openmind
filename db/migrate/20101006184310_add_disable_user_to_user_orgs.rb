class AddDisableUserToUserOrgs < ActiveRecord::Migration
  def self.up
    change_table :portal_user_org_maps do |t|
      t.datetime :user_disabled_at
    end
  end
  
  def self.down
    change_table :portal_user_org_maps do |t|
      t.remove :user_disabled_at
    end
  end
end
