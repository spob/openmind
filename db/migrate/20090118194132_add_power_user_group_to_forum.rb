class AddPowerUserGroupToForum < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    change_table :forums do |t|
      t.column 'power_user_group_id', :integer
    end
    add_foreign_key(:forums, :power_user_group_id, :groups)
  end

  def self.down
    change_table :forums do |t|
      t.remove :power_user_group_id
    end
  end
end
