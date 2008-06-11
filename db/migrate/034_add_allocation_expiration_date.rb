class AddAllocationExpirationDate < ActiveRecord::Migration
  def self.up
    add_column :allocations, :expiration_date, :date, :default => Date.jd(Date.today.jd + 120), :null => false
  end

  def self.down
    remove_column :allocations, :expiration_date
  end
end
