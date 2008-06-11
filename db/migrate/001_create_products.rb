class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :name,  :string, :limit => 30, :null => false
      t.column :description,  :string, :limit => 200, :null => false
      t.column :active, :boolean, :default => true, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :lock_version, :integer, :default => 0
    end
    
    add_index :products, :name, :unique => true
  end

  def self.down
    drop_table :products
  end
end