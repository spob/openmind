class CreateEnterprises < ActiveRecord::Migration
  def self.up
    create_table :enterprises, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :name, :string, :limit => 50, :null => false
      t.column :active, :boolean, :default => true, :null => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_index :enterprises, :name, :unique => true
  end

  def self.down
    drop_table :enterprises
  end
end