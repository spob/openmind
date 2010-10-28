class AddExpiresAtToReleaseMap < ActiveRecord::Migration
  def self.up
    change_table :serial_number_release_maps do |t|
      t.datetime :expires_at
    end
  end

  def self.down
    change_table :serial_number_release_maps do |t|
      t.remove :expires_at
    end
  end
end
