class AddViewPortalToEnterprise < ActiveRecord::Migration
  def self.up
    change_table :enterprises do |t|
      t.boolean :view_portal
    end
  end

  def self.down
    change_table :enterprises do |t|
      t.remove :view_portal
    end
  end
end
