class CreateAllocations < ActiveRecord::Migration
  def self.up 
    create_table :allocations, :options => 'DEFAULT CHARSET=utf8' do |t|
      t.column :quantity, :integer, :default => 0, :null => false 
      t.column :comments, :string, :limit => 255
      t.column :user_id,:integer
      t.column :enterprise_id,:integer
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
      t.column :lock_version, :integer, :default => 0 
      t.column :allocation_type,  :string, :limit => 30, :null => false
    end
  end

  def self.down
    drop_table :allocations
  end

end
