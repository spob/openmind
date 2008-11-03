class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.column :name,  :string, :limit => 30, :null => false
      t.column :description,  :string, :limit => 200, :null => false
      t.column :active, :boolean, :default => true, :null => false
      t.timestamps
      t.column :lock_version, :integer, :default => 0
    end
    
    add_index :products, :name, :unique => true
  end

  def self.down
    drop_table :products
  end
end