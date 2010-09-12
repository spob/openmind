class CreateSerialNumbers < ActiveRecord::Migration
  def self.up
    create_table :serial_numbers do |t|
      t.string :serial_number, :null => false, :limit => 19
      t.timestamps
    end
    add_index :serial_numbers, [:serial_number], :unique => true
  end

  def self.down
    drop_table :serial_numbers
  end
end
