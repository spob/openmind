class ConvertTimeToDateForNfrs < ActiveRecord::Migration
  def self.up
    change_column :portal_nfrs, :expires_at, :date
  end

  def self.down
    change_column :portal_nfrs, :expires_at, :datetime
  end
end
