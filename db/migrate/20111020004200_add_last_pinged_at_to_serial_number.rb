class AddLastPingedAtToSerialNumber < ActiveRecord::Migration
  def self.up
    change_table :serial_numbers do |t|
      t.timestamp :last_pinged_at, :null => true
    end
  end

  def self.down
    change_table :serial_numbers do |t|
      t.remove :last_pinged_at
    end
  end
end
