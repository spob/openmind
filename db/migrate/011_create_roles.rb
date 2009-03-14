class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :title, :string, :limit => 50, :null => false
      t.column :description, :string, :limit => 50, :null => false
      t.column :default_role, :bool, :default => false
      t.column :lock_version, :integer, :default => 0
      t.timestamps
    end
    
    add_index :roles, :title, :unique => true
  end

  def self.down
    drop_table :roles
  end
end
