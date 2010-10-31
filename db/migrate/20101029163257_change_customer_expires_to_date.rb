class ChangeCustomerExpiresToDate < ActiveRecord::Migration
  def self.up
    change_column :portal_customers, :maintenance_expires_at, :date
  end

  def self.down
    change_column :portal_customers, :maintenance_expires_at, :datetime
  end
end
